import 'package:driver_tracker/feature/trips/data/dto/request/create_trip_dto.dart';
import 'package:driver_tracker/feature/trips/data/dto/response/daily_summary_dto.dart';
import 'package:driver_tracker/feature/trips/data/dto/response/trip_dto.dart';

abstract class TripsDatasource {
  Future<List<TripDto>> getTrips(String dateStr);
  Future<DailySummaryDto> getDailySummary(String dateStr);
  Future<TripDto> addTrip(CreateTripDto request);
}
