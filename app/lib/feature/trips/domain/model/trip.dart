import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final DateTime start;
  final DateTime end;
  final double amount;
  final String payment; // 'card' or 'cash'
  final double commission;

  const Trip({
    required this.id,
    required this.start,
    required this.end,
    required this.amount,
    required this.payment,
    required this.commission,
  });

  bool get isCard => payment.toLowerCase() == 'card';
  bool get isCash => payment.toLowerCase() == 'cash';
  double get netIncome => amount - commission;
  Duration get duration => end.difference(start);

  @override
  List<Object?> get props => [id, start, end, amount, payment, commission];
}
