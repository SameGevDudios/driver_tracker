import 'dart:async';
import 'package:intl/intl.dart';
import '../dto/request/create_trip_dto.dart';
import '../dto/response/daily_summary_dto.dart';
import '../dto/response/trip_dto.dart';
import 'trips_datasource.dart';

class TripsMockDatasource implements TripsDatasource {
  final List<TripDto> _trips = [];

  TripsMockDatasource({List<TripDto>? initialData}) {
    if (initialData != null) {
      _trips.addAll(initialData);
    } else {
      _seedDefaultData();
    }
  }

  void _seedDefaultData() {
    _trips.addAll([
      // 2026-10-01 (Task reference example)
      TripDto(
        id: 't1',
        start: DateTime.parse('2026-10-01T08:10:00+05:00'),
        end: DateTime.parse('2026-10-01T08:32:00+05:00'),
        amount: 2400.0,
        payment: 'card',
        commission: 360.0,
      ),
      TripDto(
        id: 't2',
        start: DateTime.parse('2026-10-01T09:05:00+05:00'),
        end: DateTime.parse('2026-10-01T09:20:00+05:00'),
        amount: 1500.0,
        payment: 'cash',
        commission: 225.0,
      ),

      // 2026-10-02
      TripDto(
        id: 't3',
        start: DateTime.parse('2026-10-02T10:00:00+05:00'),
        end: DateTime.parse('2026-10-02T10:25:00+05:00'),
        amount: 1800.0,
        payment: 'card',
        commission: 270.0,
      ),
      TripDto(
        id: 't4',
        start: DateTime.parse('2026-10-02T11:15:00+05:00'),
        end: DateTime.parse('2026-10-02T11:45:00+05:00'),
        amount: 3200.0,
        payment: 'cash',
        commission: 480.0,
      ),
      TripDto(
        id: 't5',
        start: DateTime.parse('2026-10-02T14:30:00+05:00'),
        end: DateTime.parse('2026-10-02T15:05:00+05:00'),
        amount: 2100.0,
        payment: 'card',
        commission: 315.0,
      ),

      // 2026-10-03
      TripDto(
        id: 't6',
        start: DateTime.parse('2026-10-03T07:45:00+05:00'),
        end: DateTime.parse('2026-10-03T08:15:00+05:00'),
        amount: 1950.0,
        payment: 'card',
        commission: 292.5,
      ),
      TripDto(
        id: 't7',
        start: DateTime.parse('2026-10-03T09:00:00+05:00'),
        end: DateTime.parse('2026-10-03T09:30:00+05:00'),
        amount: 1600.0,
        payment: 'cash',
        commission: 240.0,
      ),

      // 2026-10-06 (Current day)
      TripDto(
        id: 't8',
        start: DateTime.parse('2026-10-06T08:00:00+03:00'),
        end: DateTime.parse('2026-10-06T08:30:00+03:00'),
        amount: 2800.0,
        payment: 'card',
        commission: 420.0,
      ),
      TripDto(
        id: 't9',
        start: DateTime.parse('2026-10-06T09:15:00+03:00'),
        end: DateTime.parse('2026-10-06T09:50:00+03:00'),
        amount: 1350.0,
        payment: 'cash',
        commission: 200.0,
      ),
    ]);
  }

  @override
  Future<List<TripDto>> getTrips(String dateStr) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final filtered = _trips.where((t) {
      final tripDateStr = DateFormat('yyyy-MM-dd').format(t.start);
      return tripDateStr == dateStr;
    }).toList();

    filtered.sort((a, b) => a.start.compareTo(b.start));
    return filtered;
  }

  @override
  Future<DailySummaryDto> getDailySummary(String dateStr) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final dayTrips = await getTrips(dateStr);

    final totalTrips = dayTrips.length;
    final totalAmount = dayTrips.fold<double>(0.0, (sum, t) => sum + t.amount);
    final totalCommission = dayTrips.fold<double>(0.0, (sum, t) => sum + t.commission);
    final netIncome = totalAmount - totalCommission;

    final cashTrips = dayTrips.where((t) => t.payment.toLowerCase() == 'cash').toList();
    final cardTrips = dayTrips.where((t) => t.payment.toLowerCase() == 'card').toList();

    final cashAmount = cashTrips.fold<double>(0.0, (sum, t) => sum + t.amount);
    final cardAmount = cardTrips.fold<double>(0.0, (sum, t) => sum + t.amount);

    return DailySummaryDto(
      date: dateStr,
      totalTrips: totalTrips,
      totalAmount: totalAmount,
      totalCommission: totalCommission,
      netIncome: netIncome,
      cashAmount: cashAmount,
      cardAmount: cardAmount,
      cashTripsCount: cashTrips.length,
      cardTripsCount: cardTrips.length,
    );
  }

  @override
  Future<TripDto> addTrip(CreateTripDto request) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Validation
    if (request.amount <= 0) {
      throw Exception('Сумма поездки должна быть строго больше 0.');
    }
    if (request.end.isBefore(request.start) || request.end.isAtSameMomentAs(request.start)) {
      throw Exception('Время окончания поездки должно быть позже времени начала.');
    }
    if (request.commission < 0) {
      throw Exception('Комиссия не может быть отрицательной.');
    }

    // Deduplication check 1: By ID
    if (request.id != null && request.id!.isNotEmpty) {
      final existsById = _trips.any((t) => t.id == request.id);
      if (existsById) {
        throw Exception("Поездка с идентификатором '${request.id}' уже существует.");
      }
    }

    // Deduplication check 2: By content
    final existsByContent = _trips.any((t) =>
        t.start.isAtSameMomentAs(request.start) &&
        t.end.isAtSameMomentAs(request.end) &&
        t.amount == request.amount &&
        t.payment.toLowerCase() == request.payment.toLowerCase());

    if (existsByContent) {
      throw Exception('Поездка с такими же параметрами уже существует (защита от дублей).');
    }

    final newTrip = TripDto(
      id: request.id ?? 't_${DateTime.now().millisecondsSinceEpoch}',
      start: request.start,
      end: request.end,
      amount: request.amount,
      payment: request.payment.toLowerCase(),
      commission: request.commission,
    );

    _trips.add(newTrip);
    return newTrip;
  }
}
