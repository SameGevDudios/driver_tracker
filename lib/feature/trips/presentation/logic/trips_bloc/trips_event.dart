import 'package:equatable/equatable.dart';

abstract class TripsEvent extends Equatable {
  const TripsEvent();

  @override
  List<Object?> get props => [];
}

class TripsLoadRequested extends TripsEvent {
  final DateTime date;

  const TripsLoadRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class TripsDateChanged extends TripsEvent {
  final DateTime newDate;

  const TripsDateChanged(this.newDate);

  @override
  List<Object?> get props => [newDate];
}

class TripsRefreshRequested extends TripsEvent {}
