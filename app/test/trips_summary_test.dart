import 'package:flutter_test/flutter_test.dart';
import 'package:driver_tracker/feature/trips/data/datasource/trips_mock_datasource.dart';
import 'package:driver_tracker/feature/trips/data/dto/response/trip_dto.dart';
import 'package:driver_tracker/feature/trips/data/repository/trips_repository_impl.dart';

void main() {
  group('Daily Summary Calculation Tests', () {
    test('Calculates summary for reference example (2026-10-01) correctly', () async {
      // Reference example data from prompt:
      // t1: 2026-10-01T08:10:00+05:00, amount: 2400, card, commission: 360
      // t2: 2026-10-01T09:05:00+05:00, amount: 1500, cash, commission: 225
      final mockDatasource = TripsMockDatasource();
      final repository = TripsRepositoryImpl(datasource: mockDatasource);

      final date = DateTime.parse('2026-10-01');
      final summary = await repository.getDailySummary(date);
      final trips = await repository.getTrips(date);

      // Verify trips count
      expect(trips.length, equals(2));
      expect(summary.totalTrips, equals(2));

      // Total revenue: 2400 + 1500 = 3900
      expect(summary.totalAmount, equals(3900.0));

      // Total commission: 360 + 225 = 585
      expect(summary.totalCommission, equals(585.0));

      // Net income («на руки» = amount - commission): 3900 - 585 = 3315
      expect(summary.netIncome, equals(3315.0));

      // Cash vs Card breakdown
      expect(summary.cardAmount, equals(2400.0));
      expect(summary.cardTripsCount, equals(1));

      expect(summary.cashAmount, equals(1500.0));
      expect(summary.cashTripsCount, equals(1));
    });

    test('Returns zeroed summary for date with no trips', () async {
      final mockDatasource = TripsMockDatasource(initialData: []);
      final repository = TripsRepositoryImpl(datasource: mockDatasource);

      final date = DateTime.parse('2026-10-15');
      final summary = await repository.getDailySummary(date);
      final trips = await repository.getTrips(date);

      expect(trips, isEmpty);
      expect(summary.totalTrips, equals(0));
      expect(summary.totalAmount, equals(0.0));
      expect(summary.totalCommission, equals(0.0));
      expect(summary.netIncome, equals(0.0));
      expect(summary.cashAmount, equals(0.0));
      expect(summary.cardAmount, equals(0.0));
      expect(summary.cashTripsCount, equals(0));
      expect(summary.cardTripsCount, equals(0));
    });

    test('Correctly aggregates multiple trips across payments and commissions', () async {
      final customTrips = [
        TripDto(
          id: 'custom_1',
          start: DateTime.parse('2026-10-05T08:00:00'),
          end: DateTime.parse('2026-10-05T08:30:00'),
          amount: 1000.0,
          payment: 'card',
          commission: 150.0,
        ),
        TripDto(
          id: 'custom_2',
          start: DateTime.parse('2026-10-05T09:00:00'),
          end: DateTime.parse('2026-10-05T09:40:00'),
          amount: 2000.0,
          payment: 'card',
          commission: 300.0,
        ),
        TripDto(
          id: 'custom_3',
          start: DateTime.parse('2026-10-05T10:00:00'),
          end: DateTime.parse('2026-10-05T10:20:00'),
          amount: 500.0,
          payment: 'cash',
          commission: 50.0,
        ),
      ];

      final mockDatasource = TripsMockDatasource(initialData: customTrips);
      final repository = TripsRepositoryImpl(datasource: mockDatasource);

      final summary = await repository.getDailySummary(DateTime.parse('2026-10-05'));

      expect(summary.totalTrips, equals(3));
      expect(summary.totalAmount, equals(3500.0));
      expect(summary.totalCommission, equals(500.0));
      expect(summary.netIncome, equals(3000.0));
      expect(summary.cardAmount, equals(3000.0));
      expect(summary.cashAmount, equals(500.0));
      expect(summary.cardTripsCount, equals(2));
      expect(summary.cashTripsCount, equals(1));
    });
  });
}
