using DriverTracker.Api.Data;
using DriverTracker.Api.Data.Entities;
using DriverTracker.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DriverTracker.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<AuthController> _logger;

    public AuthController(AppDbContext context, ILogger<AuthController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var hash = DbInitializer.HashPassword(request.Password);
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower() && u.PasswordHash == hash);

        if (user == null)
        {
            return Unauthorized(new { message = "Неверный email или пароль." });
        }

        var token = $"driver_token_{user.Id}_{Guid.NewGuid():N}";
        return Ok(new AuthResponse(token, user.Id, user.Email, user.FullName));
    }

    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var existing = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());

        if (existing != null)
        {
            return Conflict(new { message = "Пользователь с таким email уже существует." });
        }

        var user = new UserEntity
        {
            Id = $"u_{Guid.NewGuid():N}",
            Email = request.Email.ToLowerInvariant(),
            FullName = request.FullName,
            PasswordHash = DbInitializer.HashPassword(request.Password),
            CreatedAt = DateTimeOffset.UtcNow
        };

        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        var token = $"driver_token_{user.Id}_{Guid.NewGuid():N}";
        return Ok(new AuthResponse(token, user.Id, user.Email, user.FullName));
    }

    [HttpGet("profile")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> Profile([FromHeader(Name = "Authorization")] string? authorization)
    {
        var user = await _context.Users.FirstOrDefaultAsync();
        if (user == null)
        {
            return NotFound(new { message = "Пользователь не найден." });
        }

        return Ok(new AuthResponse("demo_token", user.Id, user.Email, user.FullName));
    }
}
