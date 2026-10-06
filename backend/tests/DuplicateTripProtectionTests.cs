using System.ComponentModel.DataAnnotations;
using DriverTracker.Api.Data;
using DriverTracker.Api.Data.Entities;
using DriverTracker.Api.Models;
using DriverTracker.Api.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace DriverTracker.Api.Tests;

public class DuplicateTripProtectionTests
{
    private AppDbContext CreateInMemoryDbContext(string dbName)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async Task AddTrip_WhenIdAlreadyExists_ThrowsDuplicateTripException()
    {
        // Arrange
        using var context = CreateInMemoryDbContext(nameof(AddTrip_WhenIdAlreadyExists_ThrowsDuplicateTripException));
        var service = new TripsService(context);

        context.Trips.Add(new TripEntity
        {
            Id = "t1",
            Start = DateTimeOffset.Parse("2026-10-01T08:10:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T08:32:00+05:00"),
            Amount = 2400m,
            Payment = "card",
            Commission = 360m
        });
        await context.SaveChangesAsync();

        var duplicateRequest = new CreateTripRequest
        {
            Id = "t1", // Same ID
            Start = DateTimeOffset.Parse("2026-10-01T12:00:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T12:30:00+05:00"),
            Amount = 1000m,
            Payment = "cash",
            Commission = 100m
        };

        // Act & Assert
        var ex = await Assert.ThrowsAsync<DuplicateTripException>(() => service.AddTripAsync(duplicateRequest));
        Assert.Contains("t1", ex.Message);
    }

    [Fact]
    public async Task AddTrip_WhenSameParametersRepeatedWithoutId_ThrowsDuplicateTripException()
    {
        // Arrange: repeating exact same trip parameters (same start, end, amount, payment)
        using var context = CreateInMemoryDbContext(nameof(AddTrip_WhenSameParametersRepeatedWithoutId_ThrowsDuplicateTripException));
        var service = new TripsService(context);

        var firstRequest = new CreateTripRequest
        {
            Start = DateTimeOffset.Parse("2026-10-01T09:05:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T09:20:00+05:00"),
            Amount = 1500m,
            Payment = "cash",
            Commission = 225m
        };

        await service.AddTripAsync(firstRequest);

        // Act & Assert: repeat sending the same trip
        var duplicateRequest = new CreateTripRequest
        {
            Start = DateTimeOffset.Parse("2026-10-01T09:05:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T09:20:00+05:00"),
            Amount = 1500m,
            Payment = "cash",
            Commission = 225m
        };

        await Assert.ThrowsAsync<DuplicateTripException>(() => service.AddTripAsync(duplicateRequest));
    }

    [Fact]
    public async Task AddTrip_WhenTripIsValidAndUnique_SuccessfullyPersistsTrip()
    {
        // Arrange
        using var context = CreateInMemoryDbContext(nameof(AddTrip_WhenTripIsValidAndUnique_SuccessfullyPersistsTrip));
        var service = new TripsService(context);

        var request = new CreateTripRequest
        {
            Id = "unique_1",
            Start = DateTimeOffset.Parse("2026-10-01T10:00:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T10:30:00+05:00"),
            Amount = 2000m,
            Payment = "card",
            Commission = 300m
        };

        // Act
        var result = await service.AddTripAsync(request);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("unique_1", result.Id);
        Assert.Equal(2000m, result.Amount);
        Assert.Equal("card", result.Payment);

        var persisted = await context.Trips.FindAsync("unique_1");
        Assert.NotNull(persisted);
    }

    [Fact]
    public async Task AddTrip_WhenAmountIsZeroOrNegative_ThrowsValidationException()
    {
        // Arrange
        using var context = CreateInMemoryDbContext(nameof(AddTrip_WhenAmountIsZeroOrNegative_ThrowsValidationException));
        var service = new TripsService(context);

        var invalidRequest = new CreateTripRequest
        {
            Start = DateTimeOffset.Parse("2026-10-01T10:00:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T10:30:00+05:00"),
            Amount = 0m, // Invalid amount
            Payment = "card",
            Commission = 0m
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => service.AddTripAsync(invalidRequest));
    }

    [Fact]
    public async Task AddTrip_WhenEndIsBeforeOrEqualToStart_ThrowsValidationException()
    {
        // Arrange
        using var context = CreateInMemoryDbContext(nameof(AddTrip_WhenEndIsBeforeOrEqualToStart_ThrowsValidationException));
        var service = new TripsService(context);

        var invalidRequest = new CreateTripRequest
        {
            Start = DateTimeOffset.Parse("2026-10-01T10:30:00+05:00"),
            End = DateTimeOffset.Parse("2026-10-01T10:00:00+05:00"), // End < Start
            Amount = 1500m,
            Payment = "card",
            Commission = 200m
        };

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => service.AddTripAsync(invalidRequest));
    }
}
