import 'package:driver_tracker/feature/trips/domain/model/trip.dart';

class TripDto {
  final String id;
  final DateTime start;
  final DateTime end;
  final double amount;
  final String payment;
  final double commission;

  const TripDto({
    required this.id,
    required this.start,
    required this.end,
    required this.amount,
    required this.payment,
    required this.commission,
  });

  factory TripDto.fromJson(Map<String, dynamic> json) => TripDto(
        id: json['id'] as String? ?? '',
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        amount: (json['amount'] as num).toDouble(),
        payment: json['payment'] as String? ?? 'card',
        commission: (json['commission'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'amount': amount,
        'payment': payment,
        'commission': commission,
      };

  Trip toDomain() => Trip(
        id: id,
        start: start,
        end: end,
        amount: amount,
        payment: payment,
        commission: commission,
      );
}
