import 'package:driver_tracker/feature/trips/domain/model/daily_summary.dart';

class DailySummaryDto {
  final String date;
  final int totalTrips;
  final double totalAmount;
  final double totalCommission;
  final double netIncome;
  final double cashAmount;
  final double cardAmount;
  final int cashTripsCount;
  final int cardTripsCount;

  const DailySummaryDto({
    required this.date,
    required this.totalTrips,
    required this.totalAmount,
    required this.totalCommission,
    required this.netIncome,
    required this.cashAmount,
    required this.cardAmount,
    this.cashTripsCount = 0,
    this.cardTripsCount = 0,
  });

  factory DailySummaryDto.fromJson(Map<String, dynamic> json) => DailySummaryDto(
        date: json['date'] as String? ?? '',
        totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
        netIncome: (json['netIncome'] as num?)?.toDouble() ?? 0.0,
        cashAmount: (json['cashAmount'] as num?)?.toDouble() ?? 0.0,
        cardAmount: (json['cardAmount'] as num?)?.toDouble() ?? 0.0,
        cashTripsCount: (json['cashTripsCount'] as num?)?.toInt() ?? 0,
        cardTripsCount: (json['cardTripsCount'] as num?)?.toInt() ?? 0,
      );

  DailySummary toDomain() => DailySummary(
        date: date,
        totalTrips: totalTrips,
        totalAmount: totalAmount,
        totalCommission: totalCommission,
        netIncome: netIncome,
        cashAmount: cashAmount,
        cardAmount: cardAmount,
        cashTripsCount: cashTripsCount,
        cardTripsCount: cardTripsCount,
      );
}
