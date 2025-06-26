using System;

namespace dotnet_service.Models
{
    public class TransactionLog
    {
        public Guid Id { get; set; }
        public string? ExternalRef { get; set; }
        public string? OperationType { get; set; } // "create_payment", "refund"
        public string? RequestData { get; set; } // JSON
        public string? ResponseData { get; set; } // JSON
        public string? Status { get; set; } // "success", "failed"
        public bool DuplicateDetected { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
} 