import '../entities/auth_result.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<AuthResult> call(String username, String password) async {
    final result = await _authRepository.login(username, password);
    if (result == AuthResult.lockedOut) {
      await _authRepository.deleteUser(username);
      // NOTE: Cart and Settings should also be deleted here.
      // We will handle this in an event listener or coordinate it differently.
    }
    return result;
  }
}

class LogoutUseCase {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.logout();
  }
}

class CheckAuthStatusUseCase {
  final IAuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  Future<String?> call() async {
    return _authRepository.getCurrentUser();
  }
}

class DeleteUserUseCase {
  final IAuthRepository _authRepository;

  DeleteUserUseCase(this._authRepository);

  Future<void> call(String username) async {
    await _authRepository.deleteUser(username);
  }
}

class GetFailedAttemptsUseCase {
  final IAuthRepository _authRepository;

  GetFailedAttemptsUseCase(this._authRepository);

  Future<int> call(String username) async {
    return _authRepository.getFailedAttempts(username);
  }
}
