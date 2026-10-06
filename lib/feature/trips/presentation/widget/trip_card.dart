import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/model/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);
    final timeFormat = DateFormat('HH:mm');

    final startTimeStr = timeFormat.format(trip.start);
    final endTimeStr = timeFormat.format(trip.end);
    final durationMinutes = trip.duration.inMinutes;

    final isCard = trip.isCard;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCard ? Colors.indigo.shade50 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCard ? Icons.credit_card_rounded : Icons.payments_outlined,
                color: isCard ? Colors.indigo.shade700 : Colors.teal.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$startTimeStr – $endTimeStr',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($durationMinutes мин)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCard ? 'Карта' : 'Наличные',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Комиссия: -${currencyFormatter.format(trip.commission)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(trip.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'На руки: ${currencyFormatter.format(trip.netIncome)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
