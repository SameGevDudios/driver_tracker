import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_tracker/common/ui/widgets/buttons/app_button.dart';
import 'package:driver_tracker/common/ui/widgets/form_fields/app_text_field.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/page_cubit/page_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля (пароль от 6 символов)')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterSubmitted(
            email: email,
            password: password,
            fullName: name,
          ),
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
              controller: _nameController,
              label: 'ФИО водителя',
              hint: 'Иванов Иван Иванович',
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _emailController,
              label: 'Электронная почта',
              hint: 'driver@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              label: 'Пароль (от 6 символов)',
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
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Зарегистрироваться',
              isLoading: isLoading,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: isLoading ? null : _submit,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Уже есть аккаунт?'),
                TextButton(
                  onPressed: () => context.read<PageCubit>().showLogin(),
                  child: const Text('Войти'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
