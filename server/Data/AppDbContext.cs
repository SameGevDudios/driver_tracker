using Microsoft.EntityFrameworkCore;
using DriverTracker.Api.Data.Entities;

namespace DriverTracker.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<TripEntity> Trips => Set<TripEntity>();
    public DbSet<UserEntity> Users => Set<UserEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<TripEntity>(entity =>
        {
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Amount).HasPrecision(18, 2);
            entity.Property(t => t.Commission).HasPrecision(18, 2);
            entity.HasIndex(t => t.Start);
        });

        modelBuilder.Entity<UserEntity>(entity =>
        {
            entity.HasKey(u => u.Id);
            entity.HasIndex(u => u.Email).IsUnique();
        });
    }
}
