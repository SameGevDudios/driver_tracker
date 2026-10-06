import 'package:intl/intl.dart';
import 'package:driver_tracker/feature/trips/domain/model/daily_summary.dart';
import 'package:driver_tracker/feature/trips/domain/model/trip.dart';
import 'package:driver_tracker/feature/trips/domain/repository/trips_repository.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_datasource.dart';
import 'package:driver_tracker/feature/trips/data/dto/request/create_trip_dto.dart';

class TripsRepositoryImpl implements TripsRepository {
  final TripsDatasource _datasource;

  TripsRepositoryImpl({required TripsDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<Trip>> getTrips(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dtos = await _datasource.getTrips(dateStr);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<DailySummary> getDailySummary(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dto = await _datasource.getDailySummary(dateStr);
    return dto.toDomain();
  }

  @override
  Future<Trip> addTrip({
    String? id,
    required DateTime start,
    required DateTime end,
    required double amount,
    required String payment,
    required double commission,
  }) async {
    final dto = await _datasource.addTrip(
      CreateTripDto(
        id: id,
        start: start,
        end: end,
        amount: amount,
        payment: payment,
        commission: commission,
      ),
    );
    return dto.toDomain();
  }
}
