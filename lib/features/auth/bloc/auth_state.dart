enum AuthStatus { unknown, authenticated, unauthenticated, lockedOut }

enum AuthFailure { none, wrongPassword, emptyFields, lockedOut }

class AuthState {
  final AuthStatus status;
  final String? username;
  final AuthFailure failure;
  final int failedAttempts;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.username,
    this.failure = AuthFailure.none,
    this.failedAttempts = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    AuthFailure? failure,
    int? failedAttempts,
  }) {
    return AuthState(
      status: status ?? this.status,
      username: username ?? this.username,
      failure: failure ?? this.failure,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}
