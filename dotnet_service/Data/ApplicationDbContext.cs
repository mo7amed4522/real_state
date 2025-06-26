using dotnet_service.Models;
using Microsoft.EntityFrameworkCore;

namespace dotnet_service.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<TransactionLog> TransactionLogs { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Configure Payment entity
            modelBuilder.Entity<Payment>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Amount).HasColumnType("decimal(12, 2)");
                entity.Property(e => e.Method).HasMaxLength(20);
                entity.Property(e => e.Status).HasMaxLength(20);
                entity.Property(e => e.Currency).HasMaxLength(10).HasDefaultValue("USD");
            });
            // Configure TransactionLog entity
            modelBuilder.Entity<TransactionLog>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.OperationType).HasMaxLength(30);
                entity.Property(e => e.Status).HasMaxLength(20);
                // In a real app, you might use a specific JSON column type if the provider supports it
                entity.Property(e => e.RequestData).HasColumnType("text"); 
                entity.Property(e => e.ResponseData).HasColumnType("text");
            });
            // Configure Invoice entity
            modelBuilder.Entity<Invoice>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne<Payment>().WithMany().HasForeignKey(i => i.PaymentId);
                entity.Property(e => e.Status).HasMaxLength(20);
            });
        }
    }
} 