namespace DriverTracker.Api.Services;

public class DuplicateTripException : Exception
{
    public DuplicateTripException(string message) : base(message)
    {
    }
}
