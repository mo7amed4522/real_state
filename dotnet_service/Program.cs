using dotnet_service.Data;
using dotnet_service.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using RedLockNet.SERedis;
using RedLockNet.SERedis.Configuration;
using StackExchange.Redis;
using Stripe;
using System.Collections.Generic;
using System.Linq;
using System;
using System.Net;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure Stripe
StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

// Configure Database Context
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));

// Configure Redis & RedLock
var redisEndpoints = builder.Configuration.GetSection("Redis:Endpoints").Get<List<string>>();
if (redisEndpoints != null && redisEndpoints.Any())
{
    var multiplexers = redisEndpoints
        .Select(e => new RedLockMultiplexer(ConnectionMultiplexer.Connect(e)))
        .ToList();
    var redlockFactory = RedLockFactory.Create(multiplexers);
    builder.Services.AddSingleton(redlockFactory);
}

// Add Custom Services
builder.Services.AddScoped<PaymentService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
