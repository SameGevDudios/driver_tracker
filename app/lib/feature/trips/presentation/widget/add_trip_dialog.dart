import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:driver_tracker/common/ui/widgets/buttons/app_button.dart';
import 'package:driver_tracker/common/ui/widgets/form_fields/app_text_field.dart';
import 'package:driver_tracker/feature/trips/presentation/logic/add_trip_cubit/add_trip_cubit.dart';
import 'package:driver_tracker/feature/trips/presentation/logic/add_trip_cubit/add_trip_state.dart';

class AddTripDialog extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onTripAdded;

  const AddTripDialog({
    super.key,
    required this.selectedDate,
    required this.onTripAdded,
  });

  @override
  State<AddTripDialog> createState() => _AddTripDialogState();
}

class _AddTripDialogState extends State<AddTripDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '1500');
  final _commissionController = TextEditingController(text: '225');
  final _idController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _paymentMethod = 'card';
  bool _autoCommission = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startTime = TimeOfDay(hour: (now.hour - 1 + 24) % 24, minute: 0);
    _endTime = TimeOfDay(hour: now.hour, minute: 25);
    _recalculateCommission();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commissionController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _recalculateCommission() {
    if (!_autoCommission) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final commission = (amount * 0.15).roundToDouble(); // 15% standard commission
    _commissionController.text = commission.toStringAsFixed(0);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Время начала поездки',
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'Время окончания поездки',
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  DateTime _buildDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = _buildDateTime(widget.selectedDate, _startTime);
    final endDateTime = _buildDateTime(widget.selectedDate, _endTime);

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final commission = double.tryParse(_commissionController.text) ?? 0.0;
    final id = _idController.text.trim();

    context.read<AddTripCubit>().submitTrip(
          id: id.isEmpty ? null : id,
          start: startDateTime,
          end: endDateTime,
          amount: amount,
          payment: _paymentMethod,
          commission: commission,
        );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dummyStart = DateTime(2026, 1, 1, _startTime.hour, _startTime.minute);
    final dummyEnd = DateTime(2026, 1, 1, _endTime.hour, _endTime.minute);

    return BlocConsumer<AddTripCubit, AddTripState>(
      listener: (context, state) {
        if (state.status == AddTripStatus.success) {
          widget.onTripAdded();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Поездка успешно добавлена!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AddTripStatus.loading;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.status == AddTripStatus.failure && state.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Times row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Начало поездки',
                            prefixIcon: const Icon(Icons.access_time_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            timeFormat.format(dummyStart),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Окончание',
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            timeFormat.format(dummyEnd),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                AppTextField(
                  controller: _amountController,
                  label: 'Сумма поездки (₽) *',
                  hint: 'Например, 1500',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_ruble_rounded),
                  onChanged: (_) => _recalculateCommission(),
                  validator: (value) {
                    final num = double.tryParse(value ?? '');
                    if (num == null || num <= 0) {
                      return 'Сумма должна быть больше 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Commission
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _commissionController,
                        label: 'Комиссия сервиса (₽)',
                        hint: '225',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: const Icon(Icons.percent_rounded),
                        validator: (value) {
                          final num = double.tryParse(value ?? '');
                          if (num == null || num < 0) {
                            return 'Комиссия не может быть отрицательной';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: FilterChip(
                        label: const Text('15%'),
                        selected: _autoCommission,
                        onSelected: (selected) {
                          setState(() {
                            _autoCommission = selected;
                            if (selected) _recalculateCommission();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment method
                const Text(
                  'Способ оплаты',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'card',
                      label: Text('Безналичные (карта)'),
                      icon: Icon(Icons.credit_card_rounded),
                    ),
                    ButtonSegment(
                      value: 'cash',
                      label: Text('Наличные'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: {_paymentMethod},
                  onSelectionChanged: (set) {
                    setState(() {
                      _paymentMethod = set.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Optional ID
                AppTextField(
                  controller: _idController,
                  label: 'ID поездки (опционально)',
                  hint: 'Оставьте пустым для автогенерации',
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Добавить поездку',
                  isLoading: isLoading,
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
