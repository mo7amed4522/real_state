using System;

namespace dotnet_service.Models
{
    public class Invoice
    {
        public Guid Id { get; set; }
        public Guid PaymentId { get; set; }
        public string? PdfUrl { get; set; }
        public string? SignedPdfUrl { get; set; }
        public string Status { get; set; } = "generated"; // "generated", "signed"
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
} 