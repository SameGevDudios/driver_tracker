class CreateTripDto {
  final String? id;
  final DateTime start;
  final DateTime end;
  final double amount;
  final String payment;
  final double commission;

  const CreateTripDto({
    this.id,
    required this.start,
    required this.end,
    required this.amount,
    required this.payment,
    required this.commission,
  });

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) 'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'amount': amount,
        'payment': payment,
        'commission': commission,
      };
}
