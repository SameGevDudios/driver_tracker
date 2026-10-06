using System.ComponentModel.DataAnnotations;
using DriverTracker.Api.Models;
using DriverTracker.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace DriverTracker.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TripsController : ControllerBase
{
    private readonly ITripsService _tripsService;
    private readonly ILogger<TripsController> _logger;

    public TripsController(ITripsService tripsService, ILogger<TripsController> logger)
    {
        _tripsService = tripsService;
        _logger = logger;
    }

    /// <summary>
    /// Получить список поездок за выбранную дату (формат YYYY-MM-DD).
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<TripDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetTrips([FromQuery] string? date)
    {
        DateOnly targetDate;
        if (string.IsNullOrWhiteSpace(date))
        {
            targetDate = DateOnly.FromDateTime(DateTime.Today);
        }
        else if (!DateOnly.TryParse(date, out targetDate))
        {
            return BadRequest(new { message = "Неверный формат даты. Ожидается формат YYYY-MM-DD." });
        }

        var trips = await _tripsService.GetTripsByDateAsync(targetDate);
        return Ok(trips);
    }

    /// <summary>
    /// Получить сводку за выбранный день: число поездок, выручка, комиссия, «на руки», разбивка наличные/карта.
    /// </summary>
    [HttpGet("summary")]
    [ProducesResponseType(typeof(DailySummaryResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetSummary([FromQuery] string? date)
    {
        DateOnly targetDate;
        if (string.IsNullOrWhiteSpace(date))
        {
            targetDate = DateOnly.FromDateTime(DateTime.Today);
        }
        else if (!DateOnly.TryParse(date, out targetDate))
        {
            return BadRequest(new { message = "Неверный формат даты. Ожидается формат YYYY-MM-DD." });
        }

        var summary = await _tripsService.GetDailySummaryAsync(targetDate);
        return Ok(summary);
    }

    /// <summary>
    /// Добавить новую поездку с валидацией и защитой от дубликатов.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(TripDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> AddTrip([FromBody] CreateTripRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var created = await _tripsService.AddTripAsync(request);
            return StatusCode(StatusCodes.Status201Created, created);
        }
        catch (DuplicateTripException ex)
        {
            _logger.LogWarning("Duplicate trip detected: {Message}", ex.Message);
            return Conflict(new { message = ex.Message, code = "DUPLICATE_TRIP" });
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning("Trip validation error: {Message}", ex.Message);
            return BadRequest(new { message = ex.Message, code = "VALIDATION_FAILED" });
        }
    }
}
