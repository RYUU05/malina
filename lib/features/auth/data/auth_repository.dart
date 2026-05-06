import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _keyCurrentUser = 'auth_current_user';
  static const _maxAttempts = 3;

  String _userKey(String username, String suffix) => 'user_${username}_$suffix';

  String _passwordKey(String username) => _userKey(username, 'password');
  String _attemptsKey(String username) => _userKey(username, 'attempts');
  String _cartKey(String username) => _userKey(username, 'cart');
  String _settingsKey(String username) => _userKey(username, 'settings');

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Check if a user with this username exists.
  Future<bool> userExists(String username) async {
    final prefs = await _prefs;
    return prefs.containsKey(_passwordKey(username));
  }

  /// Get the currently authenticated user, or null.
  Future<String?> getCurrentUser() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCurrentUser);
  }

  /// Get failed attempt count for a user.
  Future<int> getFailedAttempts(String username) async {
    final prefs = await _prefs;
    return prefs.getInt(_attemptsKey(username)) ?? 0;
  }

  /// Check if user is locked out (3+ failed attempts).
  Future<bool> isLockedOut(String username) async {
    return await getFailedAttempts(username) >= _maxAttempts;
  }

  /// Register a new user (first login with non-empty credentials).
  Future<void> _register(String username, String password) async {
    final prefs = await _prefs;
    await prefs.setString(_passwordKey(username), password);
    await prefs.setInt(_attemptsKey(username), 0);
    await prefs.setString(_cartKey(username), '');
    await prefs.setString(_settingsKey(username), '');
  }

  /// Delete a user and ALL their data (cart, settings, attempts, password).
  Future<void> deleteUser(String username) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_passwordKey(username)),
      prefs.remove(_attemptsKey(username)),
      prefs.remove(_cartKey(username)),
      prefs.remove(_settingsKey(username)),
    ]);
  }

  /// Login attempt. Returns AuthResult.
  Future<AuthResult> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return AuthResult.emptyFields;
    }

    final exists = await userExists(username);

    if (!exists) {
      // First time user — register and log in
      await _register(username, password);
      final prefs = await _prefs;
      await prefs.setString(_keyCurrentUser, username);
      return AuthResult.success;
    }

    // Existing user — check lockout first
    if (await isLockedOut(username)) {
      return AuthResult.lockedOut;
    }

    // Verify password
    final prefs = await _prefs;
    final storedPassword = prefs.getString(_passwordKey(username));

    if (storedPassword == password) {
      // Success — reset attempts
      await prefs.setInt(_attemptsKey(username), 0);
      await prefs.setString(_keyCurrentUser, username);
      return AuthResult.success;
    }

    // Wrong password — increment attempts
    final attempts = await getFailedAttempts(username) + 1;
    await prefs.setInt(_attemptsKey(username), attempts);

    if (attempts >= _maxAttempts) {
      // Delete user and all data after 3 failed attempts
      await deleteUser(username);
      return AuthResult.lockedOut;
    }

    return AuthResult.wrongPassword;
  }

  /// Logout — clear current user.
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_keyCurrentUser);
  }
}

enum AuthResult { success, wrongPassword, lockedOut, emptyFields }
