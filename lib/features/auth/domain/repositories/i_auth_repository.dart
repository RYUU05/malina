import '../entities/auth_result.dart';

abstract class IAuthRepository {
  Future<bool> userExists(String username);
  Future<String?> getCurrentUser();
  Future<int> getFailedAttempts(String username);
  Future<bool> isLockedOut(String username);
  Future<AuthResult> login(String username, String password);
  Future<void> logout();
  Future<void> deleteUser(String username);
}
