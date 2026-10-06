import 'package:equatable/equatable.dart';
import 'package:driver_tracker/feature/trips/domain/model/daily_summary.dart';
import 'package:driver_tracker/feature/trips/domain/model/trip.dart';

enum TripsStatus { initial, loading, success, failure }

class TripsState extends Equatable {
  final TripsStatus status;
  final DateTime selectedDate;
  final List<Trip> trips;
  final DailySummary summary;
  final String? errorMessage;

  const TripsState({
    this.status = TripsStatus.initial,
    required this.selectedDate,
    this.trips = const [],
    required this.summary,
    this.errorMessage,
  });

  factory TripsState.initial([DateTime? date]) {
    final d = date ?? DateTime(2026, 10, 1);
    return TripsState(
      status: TripsStatus.initial,
      selectedDate: d,
      trips: const [],
      summary: DailySummary.empty(d.toIso8601String().split('T').first),
    );
  }

  TripsState copyWith({
    TripsStatus? status,
    DateTime? selectedDate,
    List<Trip>? trips,
    DailySummary? summary,
    String? errorMessage,
  }) {
    return TripsState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      trips: trips ?? this.trips,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedDate, trips, summary, errorMessage];
}
