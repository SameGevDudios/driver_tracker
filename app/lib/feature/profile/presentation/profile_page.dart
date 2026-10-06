import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_tracker/common/config/app_config.dart';
import 'package:driver_tracker/common/navigation/navigation_routes.dart';
import 'package:driver_tracker/common/ui/widgets/buttons/app_button.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_event.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль водителя', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go(NavigationRoutes.login);
          }
        },
        builder: (context, state) {
          final user = (state is Authenticated) ? state.user : null;
          final driverName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Иван Водитель';
          final driverEmail = user?.email.isNotEmpty == true ? user!.email : 'driver@example.com';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      driverName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driverEmail,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Параметры окружения (env)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('API Сервер', config.apiBaseUrl),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Режим работы',
                        config.useMock ? 'Встроенный Mock (офлайн)' : 'ASP.NET Core REST API',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Платформы', 'Android & iOS'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Архитектура', 'Feature-Sliced Design (FSD)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Выйти из аккаунта',
                icon: Icons.logout_rounded,
                color: Colors.red.shade700,
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
