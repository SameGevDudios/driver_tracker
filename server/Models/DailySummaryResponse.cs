using System.Text.Json.Serialization;

namespace DriverTracker.Api.Models;

public record DailySummaryResponse(
    [property: JsonPropertyName("date")] string Date,
    [property: JsonPropertyName("totalTrips")] int TotalTrips,
    [property: JsonPropertyName("totalAmount")] decimal TotalAmount,
    [property: JsonPropertyName("totalCommission")] decimal TotalCommission,
    [property: JsonPropertyName("netIncome")] decimal NetIncome,
    [property: JsonPropertyName("cashAmount")] decimal CashAmount,
    [property: JsonPropertyName("cardAmount")] decimal CardAmount,
    [property: JsonPropertyName("cashTripsCount")] int CashTripsCount,
    [property: JsonPropertyName("cardTripsCount")] int CardTripsCount
);
