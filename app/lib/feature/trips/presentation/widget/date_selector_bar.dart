import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelectorBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  void _previousDay() {
    onDateChanged(selectedDate.subtract(const Duration(days: 1)));
  }

  void _nextDay() {
    onDateChanged(selectedDate.add(const Duration(days: 1)));
  }

  Future<void> _selectDateFromPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Выберите дату смены',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMMM yyyy', 'ru_RU');
    final formattedDate = dateFormat.format(selectedDate);

    final isToday = DateTime.now().year == selectedDate.year &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().day == selectedDate.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Предыдущий день',
            onPressed: _previousDay,
          ),
          InkWell(
            onTap: () => _selectDateFromPicker(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today_rounded, size: 16),
                    ],
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Сегодня',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Следующий день',
            onPressed: _nextDay,
          ),
        ],
      ),
    );
  }
}
