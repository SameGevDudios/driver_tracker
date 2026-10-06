import 'package:dio/dio.dart';
import '../../../../common/api/api_constants.dart';
import '../dto/request/create_trip_dto.dart';
import '../dto/response/daily_summary_dto.dart';
import '../dto/response/trip_dto.dart';
import 'trips_datasource.dart';

class TripsRemoteDatasource implements TripsDatasource {
  final Dio _dio;

  TripsRemoteDatasource({required Dio dio}) : _dio = dio;

  @override
  Future<List<TripDto>> getTrips(String dateStr) async {
    final response = await _dio.get(
      ApiConstants.trips,
      queryParameters: {'date': dateStr},
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => TripDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<DailySummaryDto> getDailySummary(String dateStr) async {
    final response = await _dio.get(
      ApiConstants.tripsSummary,
      queryParameters: {'date': dateStr},
    );

    return DailySummaryDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TripDto> addTrip(CreateTripDto request) async {
    final response = await _dio.post(
      ApiConstants.trips,
      data: request.toJson(),
    );

    return TripDto.fromJson(response.data as Map<String, dynamic>);
  }
}
