import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final String date;
  final int totalTrips;
  final double totalAmount;
  final double totalCommission;
  final double netIncome;
  final double cashAmount;
  final double cardAmount;
  final int cashTripsCount;
  final int cardTripsCount;

  const DailySummary({
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

  factory DailySummary.empty(String date) => DailySummary(
        date: date,
        totalTrips: 0,
        totalAmount: 0.0,
        totalCommission: 0.0,
        netIncome: 0.0,
        cashAmount: 0.0,
        cardAmount: 0.0,
        cashTripsCount: 0,
        cardTripsCount: 0,
      );

  @override
  List<Object?> get props => [
        date,
        totalTrips,
        totalAmount,
        totalCommission,
        netIncome,
        cashAmount,
        cardAmount,
        cashTripsCount,
        cardTripsCount,
      ];
}
