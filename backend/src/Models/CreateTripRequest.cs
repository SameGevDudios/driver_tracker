using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace DriverTracker.Api.Models;

public class CreateTripRequest : IValidatableObject
{
    [JsonPropertyName("id")]
    public string? Id { get; set; }

    [Required]
    [JsonPropertyName("start")]
    public DateTimeOffset Start { get; set; }

    [Required]
    [JsonPropertyName("end")]
    public DateTimeOffset End { get; set; }

    [Range(0.01, double.MaxValue, ErrorMessage = "Сумма поездки должна быть больше 0.")]
    [JsonPropertyName("amount")]
    public decimal Amount { get; set; }

    [Required]
    [RegularExpression("^(card|cash)$", ErrorMessage = "Способ оплаты должен быть 'card' или 'cash'.")]
    [JsonPropertyName("payment")]
    public string Payment { get; set; } = "card";

    [Range(0, double.MaxValue, ErrorMessage = "Комиссия не может быть отрицательной.")]
    [JsonPropertyName("commission")]
    public decimal Commission { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (End <= Start)
        {
            yield return new ValidationResult(
                "Время окончания поездки должно быть позже времени начала.",
                new[] { nameof(End) }
            );
        }

        if (Amount <= 0)
        {
            yield return new ValidationResult(
                "Сумма поездки должна быть больше 0.",
                new[] { nameof(Amount) }
            );
        }

        if (Commission < 0)
        {
            yield return new ValidationResult(
                "Комиссия не может быть отрицательной.",
                new[] { nameof(Commission) }
            );
        }
    }
}
