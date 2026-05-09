import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthLocalDataSource {
  Future<bool> userExists(String username);
  Future<String?> getCurrentUser();
  Future<int> getFailedAttempts(String username);
  Future<void> setFailedAttempts(String username, int attempts);
  Future<void> registerUser(String username, String password);
  Future<void> setCurrentUser(String username);
  Future<void> deleteUserAuthData(String username);
  Future<String?> getPassword(String username);
  Future<void> clearCurrentUser();
}

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  static const _keyCurrentUser = 'auth_current_user';
  String _userKey(String username, String suffix) => 'user_${username}_$suffix';
  String _passwordKey(String username) => _userKey(username, 'password');
  String _attemptsKey(String username) => _userKey(username, 'attempts');

  @override
  Future<bool> userExists(String username) async {
    return _prefs.containsKey(_passwordKey(username));
  }

  @override
  Future<String?> getCurrentUser() async {
    return _prefs.getString(_keyCurrentUser);
  }

  @override
  Future<int> getFailedAttempts(String username) async {
    return _prefs.getInt(_attemptsKey(username)) ?? 0;
  }

  @override
  Future<void> setFailedAttempts(String username, int attempts) async {
    await _prefs.setInt(_attemptsKey(username), attempts);
  }

  @override
  Future<void> registerUser(String username, String password) async {
    await _prefs.setString(_passwordKey(username), password);
    await _prefs.setInt(_attemptsKey(username), 0);
  }

  @override
  Future<void> setCurrentUser(String username) async {
    await _prefs.setString(_keyCurrentUser, username);
  }

  @override
  Future<void> deleteUserAuthData(String username) async {
    await Future.wait([
      _prefs.remove(_passwordKey(username)),
      _prefs.remove(_attemptsKey(username)),
    ]);
  }

  @override
  Future<String?> getPassword(String username) async {
    return _prefs.getString(_passwordKey(username));
  }

  @override
  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }
}
