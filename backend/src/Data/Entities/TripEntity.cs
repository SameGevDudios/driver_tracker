namespace DriverTracker.Api.Data.Entities;

public class TripEntity
{
    public string Id { get; set; } = string.Empty;
    public DateTimeOffset Start { get; set; }
    public DateTimeOffset End { get; set; }
    public decimal Amount { get; set; }
    public string Payment { get; set; } = "card";
    public decimal Commission { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
