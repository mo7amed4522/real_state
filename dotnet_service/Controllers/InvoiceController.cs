using dotnet_service.Models;
using dotnet_service.Services;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace dotnet_service.Controllers
{
    [ApiController]
    [Route("api/v1/invoices")]
    public class InvoiceController : ControllerBase
    {
        private readonly PaymentService _paymentService;
        public InvoiceController(PaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetInvoiceById(Guid id)
        {
            var invoice = await _paymentService.GetInvoiceByIdAsync(id);
            if (invoice == null) return NotFound();
            return Ok(invoice);
        }

        [HttpGet]
        public async Task<IActionResult> ListInvoices([FromQuery] Guid? paymentId, [FromQuery] string? status, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var invoices = await _paymentService.ListInvoicesAsync(paymentId, status, fromDate, toDate);
            return Ok(invoices);
        }
    }
} 