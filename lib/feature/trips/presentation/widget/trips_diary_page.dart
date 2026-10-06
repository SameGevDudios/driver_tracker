import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/ui/widgets/error_screen/error_screen.dart';
import '../../../../common/ui/widgets/modals/app_bottom_sheet.dart';
import '../../../../common/ui/widgets/skeleton/skeleton_loader.dart';
import '../../domain/repository/trips_repository.dart';
import '../logic/add_trip_cubit/add_trip_cubit.dart';
import '../logic/trips_bloc/trips_bloc.dart';
import '../logic/trips_bloc/trips_event.dart';
import '../logic/trips_bloc/trips_state.dart';
import 'add_trip_dialog.dart';
import 'daily_summary_card.dart';
import 'date_selector_bar.dart';
import 'trip_card.dart';

class TripsDiaryPage extends StatelessWidget {
  const TripsDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripsBloc(
        repository: context.read<TripsRepository>(),
        initialDate: DateTime(2026, 10, 1),
      )..add(TripsLoadRequested(DateTime(2026, 10, 1))),
      child: const _TripsDiaryView(),
    );
  }
}

class _TripsDiaryView extends StatelessWidget {
  const _TripsDiaryView();

  void _showAddTripModal(BuildContext context, DateTime selectedDate) {
    final tripsRepo = context.read<TripsRepository>();
    final tripsBloc = context.read<TripsBloc>();

    AppBottomSheet.show(
      context: context,
      title: 'Новая поездка',
      child: BlocProvider(
        create: (_) => AddTripCubit(repository: tripsRepo),
        child: AddTripDialog(
          selectedDate: selectedDate,
          onTripAdded: () {
            tripsBloc.add(TripsRefreshRequested());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_taxi_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Дневник смен', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить данные',
            onPressed: () => context.read<TripsBloc>().add(TripsRefreshRequested()),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<TripsBloc, TripsState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddTripModal(context, state.selectedDate),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить поездку'),
          );
        },
      ),
      body: BlocBuilder<TripsBloc, TripsState>(
        builder: (context, state) {
          return Column(
            children: [
              DateSelectorBar(
                selectedDate: state.selectedDate,
                onDateChanged: (newDate) {
                  context.read<TripsBloc>().add(TripsDateChanged(newDate));
                },
              ),
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripsState state) {
    if (state.status == TripsStatus.loading && state.trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SkeletonLoader(width: double.infinity, height: 180, borderRadius: 16),
            const SizedBox(height: 16),
            const SkeletonLoader(width: double.infinity, height: 75, borderRadius: 14),
            const SizedBox(height: 12),
            const SkeletonLoader(width: double.infinity, height: 75, borderRadius: 14),
          ],
        ),
      );
    }

    if (state.status == TripsStatus.failure && state.trips.isEmpty) {
      return ErrorScreen(
        message: state.errorMessage ?? 'Не удалось загрузить данные поездок.',
        onRetry: () => context.read<TripsBloc>().add(TripsRefreshRequested()),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TripsBloc>().add(TripsRefreshRequested());
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: DailySummaryCard(summary: state.summary),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Поездки за смену (${state.trips.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (state.status == TripsStatus.loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
          if (state.trips.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'В эту дату поездок не найдено',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Переключите день или нажмите «Добавить поездку», чтобы зафиксировать заказ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final trip = state.trips[index];
                  return TripCard(trip: trip);
                },
                childCount: state.trips.length,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
