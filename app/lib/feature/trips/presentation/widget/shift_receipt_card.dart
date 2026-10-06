import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:driver_tracker/feature/trips/domain/model/daily_summary.dart';
import 'package:driver_tracker/feature/trips/domain/model/trip.dart';

class ShiftReceiptCard extends StatelessWidget {
  final DateTime date;
  final DailySummary summary;
  final List<Trip> trips;
  final String currencySymbol;
  final VoidCallback? onCurrencyToggle;

  const ShiftReceiptCard({
    super.key,
    required this.date,
    required this.summary,
    required this.trips,
    this.currencySymbol = '₸',
    this.onCurrencyToggle,
  });

  String _formatAmount(double amount, {bool isNegative = false}) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formatted = formatter.format(amount.abs());
    final sign = isNegative ? '-' : '';
    return '$sign$formatted $currencySymbol';
  }

  String _formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const ScallopClipper(),
        child: Container(
          color: const Color(0xFFFFFDE7), // Authentic warm receipt paper tone
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Дневник смен',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(date),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            color: Color(0xFF475569),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (onCurrencyToggle != null)
                    IconButton(
                      icon: Text(
                        currencySymbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      tooltip: 'Сменить валюту (₸ / ₽)',
                      onPressed: onCurrencyToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 20),

              // Trips list
              if (trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Поездок за этот день нет',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...trips.map((trip) {
                  final startStr = timeFormat.format(trip.start);
                  final endStr = timeFormat.format(trip.end);
                  final paymentStr = trip.isCard ? 'карта' : 'нал.';
                  final amountStr = _formatAmount(trip.amount);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$startStr-$endStr  $paymentStr',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          amountStr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 12),
              _buildDashedLine(),
              const SizedBox(height: 12),

              // Summary block
              _buildReceiptRow('Поездок', summary.totalTrips.toString()),
              const SizedBox(height: 6),
              _buildReceiptRow('Выручка', _formatAmount(summary.totalAmount)),
              const SizedBox(height: 6),
              _buildReceiptRow('Комиссия', _formatAmount(summary.totalCommission, isNegative: true)),
              const SizedBox(height: 6),
              _buildReceiptRow(
                'Наличные / карта',
                '${_formatNumber(summary.cashAmount)} / ${_formatNumber(summary.cardAmount)}',
              ),

              const SizedBox(height: 14),
              _buildDashedLine(),
              const SizedBox(height: 16),

              // Big bold total "На руки"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'На руки',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _formatAmount(summary.netIncome),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }
}

class ScallopClipper extends CustomClipper<Path> {
  const ScallopClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 12);

    const scallopWidth = 14.0;
    final count = (size.width / scallopWidth).ceil();
    final actualWidth = size.width / count;

    for (int i = 0; i < count; i++) {
      final x = i * actualWidth;
      path.arcToPoint(
        Offset(x + actualWidth, size.height - 12),
        radius: Radius.circular(actualWidth / 2),
        clockwise: false,
      );
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
