using DriverTracker.Api.Data;
using DriverTracker.Api.Data.Entities;
using DriverTracker.Api.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace DriverTracker.Api.Tests;

public class SummaryCalculationTests
{
    private AppDbContext CreateInMemoryDbContext(string dbName)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async Task SummaryCalculation_WithReferenceExampleData_CalculatesCorrectly()
    {
        // Arrange: reference data from prompt
        // t1: 2400 card, commission 360
        // t2: 1500 cash, commission 225
        using var context = CreateInMemoryDbContext(nameof(SummaryCalculation_WithReferenceExampleData_CalculatesCorrectly));
        var service = new TripsService(context);

        context.Trips.AddRange(
            new TripEntity
            {
                Id = "t1",
                Start = DateTimeOffset.Parse("2026-10-01T08:10:00+05:00"),
                End = DateTimeOffset.Parse("2026-10-01T08:32:00+05:00"),
                Amount = 2400m,
                Payment = "card",
                Commission = 360m
            },
            new TripEntity
            {
                Id = "t2",
                Start = DateTimeOffset.Parse("2026-10-01T09:05:00+05:00"),
                End = DateTimeOffset.Parse("2026-10-01T09:20:00+05:00"),
                Amount = 1500m,
                Payment = "cash",
                Commission = 225m
            }
        );
        await context.SaveChangesAsync();

        // Act
        var summary = await service.GetDailySummaryAsync(DateOnly.Parse("2026-10-01"));

        // Assert
        Assert.Equal("2026-10-01", summary.Date);
        Assert.Equal(2, summary.TotalTrips);
        Assert.Equal(3900m, summary.TotalAmount); // 2400 + 1500
        Assert.Equal(585m, summary.TotalCommission); // 360 + 225
        Assert.Equal(3315m, summary.NetIncome); // 3900 - 585 = 3315 «на руки»
        Assert.Equal(1500m, summary.CashAmount);
        Assert.Equal(2400m, summary.CardAmount);
        Assert.Equal(1, summary.CashTripsCount);
        Assert.Equal(1, summary.CardTripsCount);
    }

    [Fact]
    public async Task SummaryCalculation_WhenNoTripsOnSelectedDate_ReturnsZeroedSummary()
    {
        // Arrange
        using var context = CreateInMemoryDbContext(nameof(SummaryCalculation_WhenNoTripsOnSelectedDate_ReturnsZeroedSummary));
        var service = new TripsService(context);

        // Act
        var summary = await service.GetDailySummaryAsync(DateOnly.Parse("2026-10-05"));

        // Assert
        Assert.Equal("2026-10-05", summary.Date);
        Assert.Equal(0, summary.TotalTrips);
        Assert.Equal(0m, summary.TotalAmount);
        Assert.Equal(0m, summary.TotalCommission);
        Assert.Equal(0m, summary.NetIncome);
        Assert.Equal(0m, summary.CashAmount);
        Assert.Equal(0m, summary.CardAmount);
        Assert.Equal(0, summary.CashTripsCount);
        Assert.Equal(0, summary.CardTripsCount);
    }

    [Fact]
    public void StaticCalculateSummary_WithMixedTrips_CalculatesNetAndBreakdownCorrectly()
    {
        // Arrange
        var trips = new List<TripEntity>
        {
            new() { Id = "1", Amount = 1000m, Commission = 150m, Payment = "card" },
            new() { Id = "2", Amount = 2000m, Commission = 300m, Payment = "card" },
            new() { Id = "3", Amount = 500m, Commission = 50m, Payment = "cash" },
        };

        // Act
        var summary = TripsService.CalculateSummary("2026-10-02", trips);

        // Assert
        Assert.Equal(3, summary.TotalTrips);
        Assert.Equal(3500m, summary.TotalAmount);
        Assert.Equal(500m, summary.TotalCommission);
        Assert.Equal(3000m, summary.NetIncome);
        Assert.Equal(500m, summary.CashAmount);
        Assert.Equal(3000m, summary.CardAmount);
        Assert.Equal(1, summary.CashTripsCount);
        Assert.Equal(2, summary.CardTripsCount);
    }
}
