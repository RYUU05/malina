enum AuthStatus { unknown, authenticated, unauthenticated, lockedOut }

class AuthState {
  final AuthStatus status;
  final String? username;
  final String? errorMessage;
  final int failedAttempts;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.username,
    this.errorMessage,
    this.failedAttempts = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    String? errorMessage,
    int? failedAttempts,
  }) {
    return AuthState(
      status: status ?? this.status,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}
