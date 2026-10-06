using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace DriverTracker.Api.Models;

public record LoginRequest(
    [property: Required, EmailAddress, JsonPropertyName("email")] string Email,
    [property: Required, MinLength(6), JsonPropertyName("password")] string Password
);

public record RegisterRequest(
    [property: Required, EmailAddress, JsonPropertyName("email")] string Email,
    [property: Required, MinLength(6), JsonPropertyName("password")] string Password,
    [property: Required, JsonPropertyName("fullName")] string FullName
);

public record AuthResponse(
    [property: JsonPropertyName("token")] string Token,
    [property: JsonPropertyName("userId")] string UserId,
    [property: JsonPropertyName("email")] string Email,
    [property: JsonPropertyName("fullName")] string FullName
);
