import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/auth_tab.dart';

class PageCubit extends Cubit<AuthTab> {
  PageCubit() : super(AuthTab.login);

  void showLogin() => emit(AuthTab.login);
  void showRegister() => emit(AuthTab.register);
  void toggle() => emit(state == AuthTab.login ? AuthTab.register : AuthTab.login);
}
