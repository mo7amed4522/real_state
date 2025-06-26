using System;
using System.Threading.Tasks;
using dotnet_service.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace dotnet_service.Controllers
{
    [ApiController]
    [Route("api/v1/payments")]
    public class PaymentController : ControllerBase
    {
        private readonly PaymentService _paymentService;

        public PaymentController(PaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost("create-checkout-session")]
        public async Task<IActionResult> CreateStripeCheckoutSession([FromBody] CreatePaymentRequest request)
        {
            if (request == null || request.UserId == Guid.Empty || request.PropertyId == Guid.Empty || string.IsNullOrEmpty(request.TransactionId))
                return BadRequest("Invalid request payload.");

            var (success, message, data) = await _paymentService.CreateStripeCheckoutSessionAsync(
                request.UserId,
                request.PropertyId,
                request.Amount,
                request.Currency,
                request.TransactionId
            );

            if (!success)
            {
                // Return a 409 Conflict for duplicates or busy resources, 500 for other errors
                return Conflict(new { message });
            }

            return Ok(new { message, data });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPaymentById(Guid id)
        {
            var payment = await _paymentService.GetPaymentByIdAsync(id);
            if (payment == null) return NotFound();
            return Ok(payment);
        }

        [HttpGet]
        public async Task<IActionResult> ListPayments([FromQuery] Guid? userId, [FromQuery] Guid? propertyId, [FromQuery] string? status, [FromQuery] string? method, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var payments = await _paymentService.ListPaymentsAsync(userId, propertyId, status, method, fromDate, toDate);
            return Ok(payments);
        }

        [HttpPost("manual")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> CreateManualPayment([FromBody] ManualPaymentRequest request)
        {
            var payment = await _paymentService.CreateManualPaymentAsync(request.UserId, request.PropertyId, request.Amount, request.Currency, request.Method, request.Status);
            return Ok(payment);
        }

        [HttpPatch("{id}/status")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> UpdatePaymentStatus(Guid id, [FromBody] UpdatePaymentStatusRequest request)
        {
            var result = await _paymentService.UpdatePaymentStatusAsync(id, request.Status);
            if (!result) return NotFound();
            return Ok(new { message = "Status updated" });
        }
    }

    public class CreatePaymentRequest
    {
        public Guid UserId { get; set; }
        public Guid PropertyId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "USD";
        public required string TransactionId { get; set; }
    }

    public class ManualPaymentRequest
    {
        public Guid UserId { get; set; }
        public Guid PropertyId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "USD";
        public string Method { get; set; } = "manual";
        public string Status { get; set; } = "success";
    }

    public class UpdatePaymentStatusRequest
    {
        public string Status { get; set; } = "success";
    }
} 