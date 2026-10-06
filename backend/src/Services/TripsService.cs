using DriverTracker.Api.Data;
using DriverTracker.Api.Data.Entities;
using DriverTracker.Api.Models;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace DriverTracker.Api.Services;

public interface ITripsService
{
    Task<List<TripDto>> GetTripsByDateAsync(DateOnly date);
    Task<DailySummaryResponse> GetDailySummaryAsync(DateOnly date);
    Task<TripDto> AddTripAsync(CreateTripRequest request);
}

public class TripsService : ITripsService
{
    private readonly AppDbContext _context;

    public TripsService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<TripDto>> GetTripsByDateAsync(DateOnly date)
    {
        var allTrips = await _context.Trips
            .OrderBy(t => t.Start)
            .ToListAsync();

        return allTrips
            .Where(t => DateOnly.FromDateTime(t.Start.Date) == date)
            .Select(t => new TripDto(
                t.Id,
                t.Start,
                t.End,
                t.Amount,
                t.Payment,
                t.Commission
            ))
            .ToList();
    }

    public async Task<DailySummaryResponse> GetDailySummaryAsync(DateOnly date)
    {
        var allTrips = await _context.Trips
            .OrderBy(t => t.Start)
            .ToListAsync();

        var dayTrips = allTrips
            .Where(t => DateOnly.FromDateTime(t.Start.Date) == date)
            .ToList();

        return CalculateSummary(date.ToString("yyyy-MM-dd"), dayTrips);
    }

    public async Task<TripDto> AddTripAsync(CreateTripRequest request)
    {
        if (request.Amount <= 0)
        {
            throw new ValidationException("Сумма поездки должна быть больше 0.");
        }

        if (request.End <= request.Start)
        {
            throw new ValidationException("Время окончания поездки должно быть позже времени начала.");
        }

        if (request.Commission < 0)
        {
            throw new ValidationException("Комиссия не может быть отрицательной.");
        }

        // Deduplication Check 1: By specified ID
        if (!string.IsNullOrWhiteSpace(request.Id))
        {
            var idExists = await _context.Trips.AnyAsync(t => t.Id == request.Id);
            if (idExists)
            {
                throw new DuplicateTripException($"Поездка с идентификатором '{request.Id}' уже существует в системе.");
            }
        }

        // Deduplication Check 2: By content (Start, End, Amount, Payment)
        var contentExists = await _context.Trips.AnyAsync(t =>
            t.Start == request.Start &&
            t.End == request.End &&
            t.Amount == request.Amount &&
            t.Payment.ToLower() == request.Payment.ToLower());

        if (contentExists)
        {
            throw new DuplicateTripException("Поездка с аналогичными параметрами (время начала, окончания, сумма и способ оплаты) уже сохранена.");
        }

        var tripEntity = new TripEntity
        {
            Id = string.IsNullOrWhiteSpace(request.Id) ? $"t_{Guid.NewGuid():N}" : request.Id,
            Start = request.Start,
            End = request.End,
            Amount = request.Amount,
            Payment = request.Payment.ToLowerInvariant(),
            Commission = request.Commission,
            CreatedAt = DateTimeOffset.UtcNow
        };

        await _context.Trips.AddAsync(tripEntity);
        await _context.SaveChangesAsync();

        return new TripDto(
            tripEntity.Id,
            tripEntity.Start,
            tripEntity.End,
            tripEntity.Amount,
            tripEntity.Payment,
            tripEntity.Commission
        );
    }

    public static DailySummaryResponse CalculateSummary(string dateStr, IEnumerable<TripEntity> trips)
    {
        var tripList = trips.ToList();
        var totalTrips = tripList.Count;
        var totalAmount = tripList.Sum(t => t.Amount);
        var totalCommission = tripList.Sum(t => t.Commission);
        var netIncome = totalAmount - totalCommission;

        var cashTrips = tripList.Where(t => string.Equals(t.Payment, "cash", StringComparison.OrdinalIgnoreCase)).ToList();
        var cardTrips = tripList.Where(t => string.Equals(t.Payment, "card", StringComparison.OrdinalIgnoreCase)).ToList();

        var cashAmount = cashTrips.Sum(t => t.Amount);
        var cardAmount = cardTrips.Sum(t => t.Amount);

        return new DailySummaryResponse(
            Date: dateStr,
            TotalTrips: totalTrips,
            TotalAmount: totalAmount,
            TotalCommission: totalCommission,
            NetIncome: netIncome,
            CashAmount: cashAmount,
            CardAmount: cardAmount,
            CashTripsCount: cashTrips.Count,
            CardTripsCount: cardTrips.Count
        );
    }
}
