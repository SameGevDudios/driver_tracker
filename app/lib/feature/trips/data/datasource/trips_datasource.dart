import '../dto/request/create_trip_dto.dart';
import '../dto/response/daily_summary_dto.dart';
import '../dto/response/trip_dto.dart';

abstract class TripsDatasource {
  Future<List<TripDto>> getTrips(String dateStr);
  Future<DailySummaryDto> getDailySummary(String dateStr);
  Future<TripDto> addTrip(CreateTripDto request);
}
