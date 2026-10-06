import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_tracker/common/navigation/navigation_routes.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/auth_bloc/auth_state.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/email_cubit/email_cubit.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/login_available_cubit/login_available_cubit.dart';
import 'package:driver_tracker/feature/auth/presentation/logic/page_cubit/page_cubit.dart';
import 'package:driver_tracker/feature/auth/presentation/model/auth_tab.dart';
import 'login/login_form.dart';
import 'register/register_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PageCubit()),
        BlocProvider(create: (_) => EmailCubit()),
        BlocProvider(create: (_) => LoginAvailableCubit()),
      ],
      child: const _AuthPageView(),
    );
  }
}

class _AuthPageView extends StatelessWidget {
  const _AuthPageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(NavigationRoutes.diary);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_taxi_rounded,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Дневник смен',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Учёт поездок, комиссии и дохода водителя',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<PageCubit, AuthTab>(
                        builder: (context, currentTab) {
                          return SegmentedButton<AuthTab>(
                            segments: const [
                              ButtonSegment(
                                value: AuthTab.login,
                                label: Text('Вход'),
                                icon: Icon(Icons.login_rounded),
                              ),
                              ButtonSegment(
                                value: AuthTab.register,
                                label: Text('Регистрация'),
                                icon: Icon(Icons.person_add_rounded),
                              ),
                            ],
                            selected: {currentTab},
                            onSelectionChanged: (selected) {
                              if (selected.first == AuthTab.login) {
                                context.read<PageCubit>().showLogin();
                              } else {
                                context.read<PageCubit>().showRegister();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<PageCubit, AuthTab>(
                        builder: (context, currentTab) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: currentTab == AuthTab.login
                                ? const LoginForm()
                                : const RegisterForm(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
