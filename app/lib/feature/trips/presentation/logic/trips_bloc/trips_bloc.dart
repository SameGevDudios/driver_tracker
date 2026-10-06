import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_tracker/common/utils/bloc_error_handler/bloc_error_handler.dart';
import 'package:driver_tracker/feature/trips/domain/repository/trips_repository.dart';
import 'trips_event.dart';
import 'trips_state.dart';

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  final TripsRepository _repository;

  TripsBloc({
    required TripsRepository repository,
    DateTime? initialDate,
  })  : _repository = repository,
        super(TripsState.initial(initialDate)) {
    on<TripsLoadRequested>(_onTripsLoadRequested, transformer: restartable());
    on<TripsDateChanged>(_onTripsDateChanged, transformer: restartable());
    on<TripsRefreshRequested>(_onTripsRefreshRequested, transformer: droppable());
  }

  Future<void> _loadDataForDate(DateTime date, Emitter<TripsState> emit) async {
    emit(state.copyWith(
      status: TripsStatus.loading,
      selectedDate: date,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        _repository.getTrips(date),
        _repository.getDailySummary(date),
      ]);

      final trips = results[0] as List<dynamic>;
      final summary = results[1];

      emit(state.copyWith(
        status: TripsStatus.success,
        selectedDate: date,
        trips: trips.cast(),
        summary: summary as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripsStatus.failure,
        errorMessage: BlocErrorHandler.getErrorMessage(e),
      ));
    }
  }

  Future<void> _onTripsLoadRequested(
    TripsLoadRequested event,
    Emitter<TripsState> emit,
  ) async {
    await _loadDataForDate(event.date, emit);
  }

  Future<void> _onTripsDateChanged(
    TripsDateChanged event,
    Emitter<TripsState> emit,
  ) async {
    await _loadDataForDate(event.newDate, emit);
  }

  Future<void> _onTripsRefreshRequested(
    TripsRefreshRequested event,
    Emitter<TripsState> emit,
  ) async {
    await _loadDataForDate(state.selectedDate, emit);
  }
}
