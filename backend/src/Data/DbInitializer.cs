using System.Security.Cryptography;
using System.Text;
using DriverTracker.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace DriverTracker.Api.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(AppDbContext context)
    {
        await context.Database.EnsureCreatedAsync();

        if (!await context.Users.AnyAsync())
        {
            var demoUser = new UserEntity
            {
                Id = "u_driver_1",
                Email = "driver@example.com",
                FullName = "Иван Водитель",
                PasswordHash = HashPassword("password123"),
                CreatedAt = DateTimeOffset.UtcNow
            };
            await context.Users.AddAsync(demoUser);
        }

        if (!await context.Trips.AnyAsync())
        {
            var seedTrips = new List<TripEntity>
            {
                // 2026-10-01 (Reference data from task requirements)
                new()
                {
                    Id = "t1",
                    Start = DateTimeOffset.Parse("2026-10-01T08:10:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-01T08:32:00+05:00"),
                    Amount = 2400m,
                    Payment = "card",
                    Commission = 360m,
                    CreatedAt = DateTimeOffset.UtcNow
                },
                new()
                {
                    Id = "t2",
                    Start = DateTimeOffset.Parse("2026-10-01T09:05:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-01T09:20:00+05:00"),
                    Amount = 1500m,
                    Payment = "cash",
                    Commission = 225m,
                    CreatedAt = DateTimeOffset.UtcNow
                },

                // 2026-10-02
                new()
                {
                    Id = "t3",
                    Start = DateTimeOffset.Parse("2026-10-02T10:00:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-02T10:25:00+05:00"),
                    Amount = 1800m,
                    Payment = "card",
                    Commission = 270m,
                    CreatedAt = DateTimeOffset.UtcNow
                },
                new()
                {
                    Id = "t4",
                    Start = DateTimeOffset.Parse("2026-10-02T11:15:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-02T11:45:00+05:00"),
                    Amount = 3200m,
                    Payment = "cash",
                    Commission = 480m,
                    CreatedAt = DateTimeOffset.UtcNow
                },
                new()
                {
                    Id = "t5",
                    Start = DateTimeOffset.Parse("2026-10-02T14:30:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-02T15:05:00+05:00"),
                    Amount = 2100m,
                    Payment = "card",
                    Commission = 315m,
                    CreatedAt = DateTimeOffset.UtcNow
                },

                // 2026-10-03
                new()
                {
                    Id = "t6",
                    Start = DateTimeOffset.Parse("2026-10-03T07:45:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-03T08:15:00+05:00"),
                    Amount = 1950m,
                    Payment = "card",
                    Commission = 292.5m,
                    CreatedAt = DateTimeOffset.UtcNow
                },
                new()
                {
                    Id = "t7",
                    Start = DateTimeOffset.Parse("2026-10-03T09:00:00+05:00"),
                    End = DateTimeOffset.Parse("2026-10-03T09:30:00+05:00"),
                    Amount = 1600m,
                    Payment = "cash",
                    Commission = 240m,
                    CreatedAt = DateTimeOffset.UtcNow
                },

                // 2026-10-06 (Current day)
                new()
                {
                    Id = "t8",
                    Start = DateTimeOffset.Parse("2026-10-06T08:00:00+03:00"),
                    End = DateTimeOffset.Parse("2026-10-06T08:30:00+03:00"),
                    Amount = 2800m,
                    Payment = "card",
                    Commission = 420m,
                    CreatedAt = DateTimeOffset.UtcNow
                },
                new()
                {
                    Id = "t9",
                    Start = DateTimeOffset.Parse("2026-10-06T09:15:00+03:00"),
                    End = DateTimeOffset.Parse("2026-10-06T09:50:00+03:00"),
                    Amount = 1350m,
                    Payment = "cash",
                    Commission = 200m,
                    CreatedAt = DateTimeOffset.UtcNow
                }
            };

            await context.Trips.AddRangeAsync(seedTrips);
        }

        await context.SaveChangesAsync();
    }

    public static string HashPassword(string password)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
