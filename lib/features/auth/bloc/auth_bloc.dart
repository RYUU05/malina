import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserDeleted>(_onUserDeleted);
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _repo.checkStatus();
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, username: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _repo.login(event.username, event.password);

    switch (result) {
      case AuthResult.success:
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          username: event.username,
          failure: AuthFailure.none,
          failedAttempts: 0,
        ));
      case AuthResult.wrongPassword:
        final attempts = _repo.getFailedAttempts(event.username);
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          failure: AuthFailure.wrongPassword,
          failedAttempts: attempts,
        ));
      case AuthResult.lockedOut:
        emit(state.copyWith(
          status: AuthStatus.lockedOut,
          failure: AuthFailure.lockedOut,
          failedAttempts: 3,
        ));
      case AuthResult.emptyFields:
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          failure: AuthFailure.emptyFields,
        ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onUserDeleted(
    AuthUserDeleted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.username != null) {
      await _repo.deleteUser(state.username!);
    }
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}

