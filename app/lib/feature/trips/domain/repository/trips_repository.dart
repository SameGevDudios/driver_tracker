import '../model/daily_summary.dart';
import '../model/trip.dart';

abstract class TripsRepository {
  Future<List<Trip>> getTrips(DateTime date);
  Future<DailySummary> getDailySummary(DateTime date);
  Future<Trip> addTrip({
    String? id,
    required DateTime start,
    required DateTime end,
    required double amount,
    required String payment,
    required double commission,
  });
}
