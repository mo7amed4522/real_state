using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using dotnet_service.Data;
using dotnet_service.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using RedLockNet.SERedis;
using Stripe.Checkout;

namespace dotnet_service.Services
{
    public class PaymentService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly RedLockFactory _redLockFactory;
        private readonly IConfiguration _configuration;

        public PaymentService(ApplicationDbContext dbContext, RedLockFactory redLockFactory, IConfiguration configuration)
        {
            _dbContext = dbContext;
            _redLockFactory = redLockFactory;
            _configuration = configuration;
        }

        public async Task<(bool Success, string Message, object Data)> CreateStripeCheckoutSessionAsync(Guid userId, Guid propertyId, decimal amount, string currency, string clientTransactionId)
        {
            var lockResource = $"property_payment:{propertyId}";
            var expiry = TimeSpan.FromSeconds(30);

            await using (var redLock = await _redLockFactory.CreateLockAsync(lockResource, expiry))
            {
                if (!redLock.IsAcquired)
                {
                    return (false, "Property is currently being processed by another transaction. Please try again shortly.", null);
                }

                if (await _dbContext.TransactionLogs.AnyAsync(t => t.ExternalRef == clientTransactionId))
                {
                    return (false, "Duplicate transaction ID provided.", null);
                }

                await using (var dbTransaction = await _dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var payment = new Payment
                        {
                            Id = Guid.NewGuid(),
                            UserId = userId,
                            PropertyId = propertyId,
                            Amount = amount,
                            Currency = currency.ToLower(),
                            Method = "stripe",
                            Status = "pending",
                        };
                        _dbContext.Payments.Add(payment);
                        await _dbContext.SaveChangesAsync();

                        var options = new SessionCreateOptions
                        {
                            PaymentMethodTypes = new() { "card" },
                            LineItems = new()
                            {
                                new SessionLineItemOptions
                                {
                                    PriceData = new SessionLineItemPriceDataOptions
                                    {
                                        UnitAmount = (long)(amount * 100), // Amount in cents
                                        Currency = currency.ToLower(),
                                        ProductData = new SessionLineItemPriceDataProductDataOptions
                                        {
                                            Name = $"Property Purchase: {propertyId}",
                                        },
                                    },
                                    Quantity = 1,
                                },
                            },
                            Mode = "payment",
                            SuccessUrl = _configuration["Stripe:SuccessUrl"],
                            CancelUrl = _configuration["Stripe:CancelUrl"],
                            Metadata = new()
                            {
                                { "payment_id", payment.Id.ToString() },
                                { "user_id", userId.ToString() }
                            }
                        };

                        var service = new SessionService();
                        Session session = await service.CreateAsync(options);

                        payment.StripeSessionId = session.Id;
                        _dbContext.Payments.Update(payment);

                        var log = new TransactionLog
                        {
                            ExternalRef = clientTransactionId,
                            OperationType = "create_checkout_session",
                            RequestData = JsonSerializer.Serialize(options),
                            ResponseData = JsonSerializer.Serialize(session),
                            Status = "success",
                        };
                        _dbContext.TransactionLogs.Add(log);

                        await _dbContext.SaveChangesAsync();
                        await dbTransaction.CommitAsync();

                        return (true, "Stripe Checkout Session created.", new { sessionId = session.Id });
                    }
                    catch (Exception ex)
                    {
                        await dbTransaction.RollbackAsync();
                        // Consider logging the exception ex
                        return (false, "An error occurred while creating the payment session.", null);
                    }
                }
            }
        }

        public async Task<Payment?> GetPaymentByIdAsync(Guid id)
        {
            return await _dbContext.Payments.FindAsync(id);
        }

        public async Task<List<Payment>> ListPaymentsAsync(Guid? userId = null, Guid? propertyId = null, string? status = null, string? method = null, DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _dbContext.Payments.AsQueryable();
            if (userId.HasValue) query = query.Where(p => p.UserId == userId);
            if (propertyId.HasValue) query = query.Where(p => p.PropertyId == propertyId);
            if (!string.IsNullOrEmpty(status)) query = query.Where(p => p.Status == status);
            if (!string.IsNullOrEmpty(method)) query = query.Where(p => p.Method == method);
            if (fromDate.HasValue) query = query.Where(p => p.CreatedAt >= fromDate);
            if (toDate.HasValue) query = query.Where(p => p.CreatedAt <= toDate);
            return await query.OrderByDescending(p => p.CreatedAt).ToListAsync();
        }
        public async Task<Payment> CreateManualPaymentAsync(Guid userId, Guid propertyId, decimal amount, string currency, string method, string status)
        {
            var payment = new Payment
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                PropertyId = propertyId,
                Amount = amount,
                Currency = currency,
                Method = method,
                Status = status,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _dbContext.Payments.Add(payment);
            await _dbContext.SaveChangesAsync();
            return payment;
        }

        public async Task<bool> UpdatePaymentStatusAsync(Guid id, string status)
        {
            var payment = await _dbContext.Payments.FindAsync(id);
            if (payment == null) return false;
            payment.Status = status;
            payment.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<List<TransactionLog>> ListTransactionLogsAsync(string? externalRef = null, string? operationType = null, string? status = null, DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _dbContext.TransactionLogs.AsQueryable();
            if (!string.IsNullOrEmpty(externalRef)) query = query.Where(t => t.ExternalRef == externalRef);
            if (!string.IsNullOrEmpty(operationType)) query = query.Where(t => t.OperationType == operationType);
            if (!string.IsNullOrEmpty(status)) query = query.Where(t => t.Status == status);
            if (fromDate.HasValue) query = query.Where(t => t.CreatedAt >= fromDate);
            if (toDate.HasValue) query = query.Where(t => t.CreatedAt <= toDate);
            return await query.OrderByDescending(t => t.CreatedAt).ToListAsync();
        }

        public async Task<Invoice?> GetInvoiceByIdAsync(Guid id)
        {
            return await _dbContext.Invoices.FindAsync(id);
        }

        public async Task<List<Invoice>> ListInvoicesAsync(Guid? paymentId = null, string? status = null, DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _dbContext.Invoices.AsQueryable();
            if (paymentId.HasValue) query = query.Where(i => i.PaymentId == paymentId);
            if (!string.IsNullOrEmpty(status)) query = query.Where(i => i.Status == status);
            if (fromDate.HasValue) query = query.Where(i => i.CreatedAt >= fromDate);
            if (toDate.HasValue) query = query.Where(i => i.CreatedAt <= toDate);
            return await query.OrderByDescending(i => i.CreatedAt).ToListAsync();
        }
    }
} 