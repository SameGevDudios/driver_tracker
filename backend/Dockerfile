# Multi-stage Dockerfile for ASP.NET Core API (.NET 10)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy project file and restore
COPY src/DriverTracker.Api.csproj src/
RUN dotnet restore "src/DriverTracker.Api.csproj"

# Copy remaining source code and publish
COPY src/ src/
WORKDIR "/app/src"
RUN dotnet publish "DriverTracker.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "DriverTracker.Api.dll"]
