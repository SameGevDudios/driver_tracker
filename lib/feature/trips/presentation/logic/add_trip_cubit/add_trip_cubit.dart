import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_tracker/common/utils/bloc_error_handler/bloc_error_handler.dart';
import 'package:driver_tracker/feature/trips/domain/repository/trips_repository.dart';
import 'add_trip_state.dart';

class AddTripCubit extends Cubit<AddTripState> {
  final TripsRepository _repository;

  AddTripCubit({required TripsRepository repository})
      : _repository = repository,
        super(const AddTripState());

  Future<void> submitTrip({
    String? id,
    required DateTime start,
    required DateTime end,
    required double amount,
    required String payment,
    required double commission,
  }) async {
    // Client-side validations
    if (amount <= 0) {
      emit(state.copyWith(
        status: AddTripStatus.failure,
        errorMessage: 'Сумма поездки должна быть больше 0.',
      ));
      return;
    }

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      emit(state.copyWith(
        status: AddTripStatus.failure,
        errorMessage: 'Время окончания поездки должно быть позже времени начала.',
      ));
      return;
    }

    if (commission < 0) {
      emit(state.copyWith(
        status: AddTripStatus.failure,
        errorMessage: 'Комиссия не может быть отрицательной.',
      ));
      return;
    }

    emit(state.copyWith(status: AddTripStatus.loading, errorMessage: null));

    try {
      final trip = await _repository.addTrip(
        id: id,
        start: start,
        end: end,
        amount: amount,
        payment: payment,
        commission: commission,
      );

      emit(state.copyWith(
        status: AddTripStatus.success,
        addedTrip: trip,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddTripStatus.failure,
        errorMessage: BlocErrorHandler.getErrorMessage(e),
      ));
    }
  }

  void reset() {
    emit(const AddTripState());
  }
}
