import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDataSource _localDataSource;
  static const _maxAttempts = 3;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<bool> userExists(String username) {
    return _localDataSource.userExists(username);
  }

  @override
  Future<String?> getCurrentUser() {
    return _localDataSource.getCurrentUser();
  }

  @override
  Future<int> getFailedAttempts(String username) {
    return _localDataSource.getFailedAttempts(username);
  }

  @override
  Future<bool> isLockedOut(String username) async {
    return await getFailedAttempts(username) >= _maxAttempts;
  }

  @override
  Future<void> deleteUser(String username) async {
    await _localDataSource.deleteUserAuthData(username);
  }

  @override
  Future<AuthResult> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return AuthResult.emptyFields;
    }

    final exists = await userExists(username);

    if (!exists) {
      await _localDataSource.registerUser(username, password);
      await _localDataSource.setCurrentUser(username);
      return AuthResult.success;
    }

    if (await isLockedOut(username)) {
      return AuthResult.lockedOut;
    }

    final storedPassword = await _localDataSource.getPassword(username);

    if (storedPassword == password) {
      await _localDataSource.setFailedAttempts(username, 0);
      await _localDataSource.setCurrentUser(username);
      return AuthResult.success;
    }

    final attempts = await getFailedAttempts(username) + 1;
    await _localDataSource.setFailedAttempts(username, attempts);

    if (attempts >= _maxAttempts) {
      // In a real app, business logic like "delete user after 3 failed attempts" 
      // is usually in a UseCase. For now, we leave it here or move it to LoginUseCase.
      // Let's keep repository just returning the result, and UseCase orchestrates deletion.
      return AuthResult.lockedOut;
    }

    return AuthResult.wrongPassword;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearCurrentUser();
  }
}
