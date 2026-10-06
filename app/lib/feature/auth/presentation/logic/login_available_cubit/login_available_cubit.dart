import 'package:flutter_bloc/flutter_bloc.dart';

class LoginAvailableCubit extends Cubit<bool> {
  LoginAvailableCubit() : super(false);

  void validate({required String email, required String password}) {
    final isEmailValid =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
    final isPasswordValid = password.trim().length >= 6;
    emit(isEmailValid && isPasswordValid);
  }
}
