abstract class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  const AuthLoginRequested({required this.username, required this.password});
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

final class AuthUserDeleted extends AuthEvent {
  const AuthUserDeleted();
}
