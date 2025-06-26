using System;

namespace dotnet_service.Models
{
    public class Payment
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid PropertyId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "USD";
        public string? Method { get; set; } // "stripe", "google_pay", "apple_pay"
        public string? Status { get; set; } // "pending", "success", "failed", "refunded"
        public string? StripeSessionId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
} 