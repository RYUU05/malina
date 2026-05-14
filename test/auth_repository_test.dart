import 'package:flutter_test/flutter_test.dart';
import 'package:malina/features/auth/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthRepository', () {
    late SharedPreferences prefs;
    late AuthRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = AuthRepository(prefs);
    });

    test('stores user on successful login', () async {
      final result = await repository.login('user@example.com', 'admin123');

      expect(result, AuthResult.success);
      expect(await repository.checkStatus(), 'user@example.com');
      expect(repository.getFailedAttempts('user@example.com'), 0);
    });

    test('locks account after three failed attempts', () async {
      await repository.login('user@example.com', 'wrongpass');
      await repository.login('user@example.com', 'wrongpass');
      final result = await repository.login('user@example.com', 'wrongpass');

      expect(result, AuthResult.lockedOut);
      expect(await repository.checkStatus(), isNull);
      expect(repository.getFailedAttempts('user@example.com'), 3);
    });

    test('removes persisted data when user is deleted', () async {
      await repository.login('user@example.com', 'admin123');

      await repository.deleteUser('user@example.com');

      expect(await repository.checkStatus(), isNull);
      expect(repository.getFailedAttempts('user@example.com'), 0);
    });
  });
}
