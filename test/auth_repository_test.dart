import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:malina/features/auth/data/auth_repository.dart';

void main() {
  late AuthRepository authRepo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authRepo = AuthRepository();
  });

  test('successful login registers new user and returns success', () async {
    final result = await authRepo.login('alice', 'pass123');

    expect(result, AuthResult.success);
    expect(await authRepo.userExists('alice'), isTrue);
    expect(await authRepo.getCurrentUser(), 'alice');
  });

  test('3 failed attempts delete user and return lockedOut', () async {
    // Register user
    await authRepo.login('bob', 'secret');

    // 3 wrong password attempts
    final r1 = await authRepo.login('bob', 'wrong1');
    expect(r1, AuthResult.wrongPassword);
    expect(await authRepo.getFailedAttempts('bob'), 1);

    final r2 = await authRepo.login('bob', 'wrong2');
    expect(r2, AuthResult.wrongPassword);
    expect(await authRepo.getFailedAttempts('bob'), 2);

    final r3 = await authRepo.login('bob', 'wrong3');
    expect(r3, AuthResult.lockedOut);

    // User and all data deleted
    expect(await authRepo.userExists('bob'), isFalse);
  });
}
