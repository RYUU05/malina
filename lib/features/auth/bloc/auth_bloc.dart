import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/auth_result.dart';
import '../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final GetFailedAttemptsUseCase _getFailedAttemptsUseCase;

  AuthBloc(
    this._loginUseCase,
    this._logoutUseCase,
    this._checkAuthStatusUseCase,
    this._deleteUserUseCase,
    this._getFailedAttemptsUseCase,
  ) : super(const AuthState()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserDeleted>(_onUserDeleted);
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _checkAuthStatusUseCase();
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
    final result = await _loginUseCase(event.username, event.password);

    switch (result) {
      case AuthResult.success:
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            username: event.username,
            failure: AuthFailure.none,
            failedAttempts: 0,
          ),
        );
      case AuthResult.wrongPassword:
        final attempts = await _getFailedAttemptsUseCase(event.username);
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            failure: AuthFailure.wrongPassword,
            failedAttempts: attempts,
          ),
        );
      case AuthResult.lockedOut:
        emit(
          state.copyWith(
            status: AuthStatus.lockedOut,
            failure: AuthFailure.lockedOut,
            failedAttempts: 3,
          ),
        );
      case AuthResult.emptyFields:
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            failure: AuthFailure.emptyFields,
          ),
        );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onUserDeleted(
    AuthUserDeleted event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _checkAuthStatusUseCase();
    if (currentUser != null) {
      await _deleteUserUseCase(currentUser);
    }
    await _logoutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
