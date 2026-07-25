import 'package:chumley_navigator/screens/login/repo/login_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginInitial());

  final LoginRepository _repository;

  /// Optional cleanup hook (e.g. close chat socket / clear chat JWT).
  Future<void> Function()? onAfterLogout;

  Future<void> checkAuthStatus() async {
    emit(const LoginLoading());
    try {
      final user = await _repository.checkAuth();
      if (user == null) {
        emit(const LoginUnauthenticated());
        return;
      }
      emit(LoginAuthenticated(user));
    } catch (e) {
      await _repository.logout();
      emit(const LoginUnauthenticated());
    }
  }

  Future<void> login() async {
    emit(const LoginLoading());
    try {
      final user = await _repository.login();
      emit(LoginAuthenticated(user));
    } on LoginException catch (e) {
      emit(LoginError(e.message));
      emit(const LoginUnauthenticated());
    } catch (_) {
      emit(const LoginError('Unable to sign in. Please try again.'));
      emit(const LoginUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(const LoginLoading());
    await _repository.logout();
    await onAfterLogout?.call();
    emit(const LoginUnauthenticated());
  }

  void markUnauthenticated() {
    emit(const LoginUnauthenticated());
  }
}
