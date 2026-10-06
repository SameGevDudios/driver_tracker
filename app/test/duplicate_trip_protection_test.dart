import 'package:flutter_test/flutter_test.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_mock_datasource.dart';
import 'package:driver_tracker/feature/trips/data/repository/trips_repository_impl.dart';

void main() {
  group('Trip Validation & Duplicate Protection Tests', () {
    late TripsMockDatasource mockDatasource;
    late TripsRepositoryImpl repository;

    setUp(() {
      mockDatasource = TripsMockDatasource();
      repository = TripsRepositoryImpl(datasource: mockDatasource);
    });

    test('Throws exception when adding a trip with an existing ID', () async {
      // 't1' already exists in default seed data
      expect(
        () => repository.addTrip(
          id: 't1',
          start: DateTime.parse('2026-10-01T12:00:00+05:00'),
          end: DateTime.parse('2026-10-01T12:30:00+05:00'),
          amount: 1200.0,
          payment: 'card',
          commission: 180.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains("идентификатором 't1' уже существует"))),
      );
    });

    test('Throws exception when resending exact same trip (duplicate protection by content)', () async {
      final start = DateTime.parse('2026-10-01T15:00:00+05:00');
      final end = DateTime.parse('2026-10-01T15:25:00+05:00');

      // First submission - should succeed
      final trip1 = await repository.addTrip(
        start: start,
        end: end,
        amount: 1850.0,
        payment: 'card',
        commission: 277.5,
      );
      expect(trip1.amount, equals(1850.0));

      // Second submission of the exact same trip - should be blocked
      expect(
        () => repository.addTrip(
          start: start,
          end: end,
          amount: 1850.0,
          payment: 'card',
          commission: 277.5,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('защита от дублей'))),
      );
    });

    test('Validates that amount must be greater than 0', () async {
      expect(
        () => repository.addTrip(
          start: DateTime.parse('2026-10-01T16:00:00+05:00'),
          end: DateTime.parse('2026-10-01T16:20:00+05:00'),
          amount: 0.0, // Invalid amount
          payment: 'cash',
          commission: 0.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('больше 0'))),
      );

      expect(
        () => repository.addTrip(
          start: DateTime.parse('2026-10-01T16:00:00+05:00'),
          end: DateTime.parse('2026-10-01T16:20:00+05:00'),
          amount: -500.0, // Negative amount
          payment: 'cash',
          commission: 0.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('больше 0'))),
      );
    });

    test('Validates that end time must be after start time', () async {
      expect(
        () => repository.addTrip(
          start: DateTime.parse('2026-10-01T16:30:00+05:00'),
          end: DateTime.parse('2026-10-01T16:00:00+05:00'), // End < Start
          amount: 1000.0,
          payment: 'card',
          commission: 150.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('позже времени начала'))),
      );

      expect(
        () => repository.addTrip(
          start: DateTime.parse('2026-10-01T16:00:00+05:00'),
          end: DateTime.parse('2026-10-01T16:00:00+05:00'), // End == Start
          amount: 1000.0,
          payment: 'card',
          commission: 150.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('позже времени начала'))),
      );
    });

    test('Validates that commission cannot be negative', () async {
      expect(
        () => repository.addTrip(
          start: DateTime.parse('2026-10-01T17:00:00+05:00'),
          end: DateTime.parse('2026-10-01T17:30:00+05:00'),
          amount: 1000.0,
          payment: 'card',
          commission: -50.0,
        ),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('не может быть отрицательной'))),
      );
    });

    test('Successfully adds a valid and unique trip', () async {
      final trip = await repository.addTrip(
        id: 'new_unique_id',
        start: DateTime.parse('2026-10-01T18:00:00+05:00'),
        end: DateTime.parse('2026-10-01T18:45:00+05:00'),
        amount: 2500.0,
        payment: 'card',
        commission: 375.0,
      );

      expect(trip.id, equals('new_unique_id'));
      expect(trip.amount, equals(2500.0));
      expect(trip.commission, equals(375.0));
      expect(trip.netIncome, equals(2125.0));
    });
  });
}
