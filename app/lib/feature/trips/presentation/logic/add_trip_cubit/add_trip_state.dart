import 'package:equatable/equatable.dart';
import 'package:driver_tracker/feature/trips/domain/model/trip.dart';

enum AddTripStatus { initial, loading, success, failure }

class AddTripState extends Equatable {
  final AddTripStatus status;
  final Trip? addedTrip;
  final String? errorMessage;

  const AddTripState({
    this.status = AddTripStatus.initial,
    this.addedTrip,
    this.errorMessage,
  });

  AddTripState copyWith({
    AddTripStatus? status,
    Trip? addedTrip,
    String? errorMessage,
  }) {
    return AddTripState(
      status: status ?? this.status,
      addedTrip: addedTrip ?? this.addedTrip,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, addedTrip, errorMessage];
}
