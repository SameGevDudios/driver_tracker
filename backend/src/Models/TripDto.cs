using System.Text.Json.Serialization;

namespace DriverTracker.Api.Models;

public record TripDto(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("start")] DateTimeOffset Start,
    [property: JsonPropertyName("end")] DateTimeOffset End,
    [property: JsonPropertyName("amount")] decimal Amount,
    [property: JsonPropertyName("payment")] string Payment,
    [property: JsonPropertyName("commission")] decimal Commission
);
