import 'package:flutter_bloc/flutter_bloc.dart';

class EmailCubit extends Cubit<String> {
  EmailCubit({String initialEmail = ''}) : super(initialEmail);

  void updateEmail(String email) => emit(email.trim());

  bool get isValid =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state);
}
