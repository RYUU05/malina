import 'package:shared_preferences/shared_preferences.dart';

enum AuthResult { success, wrongPassword, lockedOut, emptyFields }

class AuthRepository {
  final SharedPreferences _prefs;
  static const _keyUser = 'auth_user';
  static const _keyAttempts = 'auth_attempts';

  AuthRepository(this._prefs);

  Future<String?> checkStatus() async {
    return _prefs.getString(_keyUser);
  }

  Future<AuthResult> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return AuthResult.emptyFields;

    // Имитация логики: пароль должен быть 'admin'
    if (password == 'admin') {
      await _prefs.setString(_keyUser, username);
      await _prefs.setInt(_keyAttempts + username, 0);
      return AuthResult.success;
    }

    final attempts = (_prefs.getInt(_keyAttempts + username) ?? 0) + 1;
    await _prefs.setInt(_keyAttempts + username, attempts);

    if (attempts >= 3) {
      await logout(); // Удаляем пользователя если он был
      return AuthResult.lockedOut;
    }

    return AuthResult.wrongPassword;
  }

  Future<void> logout() async {
    await _prefs.remove(_keyUser);
  }

  Future<void> deleteUser(String username) async {
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyAttempts + username);
  }

  int getFailedAttempts(String username) {
    return _prefs.getInt(_keyAttempts + username) ?? 0;
  }
}
