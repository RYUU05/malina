import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserDeleted>(_onUserDeleted);
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(
        state.copyWith(status: AuthStatus.authenticated, username: currentUser),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.login(event.username, event.password);

    switch (result) {
      case AuthResult.success:
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            username: event.username,
            errorMessage: '',
            failedAttempts: 0,
          ),
        );
      case AuthResult.wrongPassword:
        final attempts = await _authRepository.getFailedAttempts(
          event.username,
        );
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Неверный пароль. Попыток осталось: ${3 - attempts}',
            failedAttempts: attempts,
          ),
        );
      case AuthResult.lockedOut:
        emit(
          state.copyWith(
            status: AuthStatus.lockedOut,
            errorMessage: 'Аккаунт заблокирован. Пользователь удалён.',
            failedAttempts: 3,
          ),
        );
      case AuthResult.emptyFields:
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Заполните все поля',
          ),
        );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onUserDeleted(
    AuthUserDeleted event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null) {
      await _authRepository.deleteUser(currentUser);
    }
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
