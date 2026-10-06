import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_tracker/common/ui/widgets/buttons/app_button.dart';
import 'package:driver_tracker/common/ui/widgets/form_fields/app_text_field.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/email_cubit/email_cubit.dart';
import '../../logic/login_available_cubit/login_available_cubit.dart';
import '../../logic/page_cubit/page_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController(text: 'driver@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFormChanged();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _notifyFormChanged() {
    context.read<EmailCubit>().updateEmail(_emailController.text);
    context.read<LoginAvailableCubit>().validate(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
          AuthLoginSubmitted(email: email, password: password),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoading = authState is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'Электронная почта',
              hint: 'driver@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              onChanged: (_) => _notifyFormChanged(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Пароль',
              hint: '••••••••',
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              onChanged: (_) => _notifyFormChanged(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _emailController.text = 'driver@example.com';
                  _passwordController.text = 'password123';
                  _notifyFormChanged();
                },
                child: const Text(
                  'Заполнить демо-водителя',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<LoginAvailableCubit, bool>(
              builder: (context, isAvailable) {
                return AppButton(
                  text: 'Войти',
                  isLoading: isLoading,
                  icon: Icons.login_rounded,
                  onPressed: isAvailable && !isLoading ? _submit : null,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Нет аккаунта водителя?'),
                TextButton(
                  onPressed: () => context.read<PageCubit>().showRegister(),
                  child: const Text('Зарегистрироваться'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
