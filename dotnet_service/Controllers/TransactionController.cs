using dotnet_service.Models;
using dotnet_service.Services;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace dotnet_service.Controllers
{
    [ApiController]
    [Route("api/v1/transactions")]
    public class TransactionController : ControllerBase
    {
        private readonly PaymentService _paymentService;
        public TransactionController(PaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpGet]
        public async Task<IActionResult> ListTransactionLogs([FromQuery] string? externalRef, [FromQuery] string? operationType, [FromQuery] string? status, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var logs = await _paymentService.ListTransactionLogsAsync(externalRef, operationType, status, fromDate, toDate);
            return Ok(logs);
        }
    }
} 