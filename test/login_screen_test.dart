import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:malina/features/auth/bloc/auth_bloc.dart';
import 'package:malina/features/auth/bloc/auth_event.dart';
import 'package:malina/features/auth/bloc/auth_state.dart';
import 'package:malina/features/auth/data/auth_repository.dart';
import 'package:malina/features/auth/presentation/login_page.dart';

void main() {
  late AuthRepository authRepo;
  late AuthBloc authBloc;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authRepo = AuthRepository();
    authBloc = AuthBloc(authRepo);
  });

  tearDown(() {
    authBloc.close();
  });

  Widget createTestWidget() {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const MaterialApp(home: LoginPage()),
    );
  }

  testWidgets('LoginScreen shows email and password fields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.runAsync(() async {
      authBloc.add(const AuthStatusChecked());
      await authBloc.stream.firstWhere((s) => s.status != AuthStatus.unknown);
    });
    await tester.pumpAndSettle();

    expect(find.text('Почта'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('LoginScreen shows form validation errors on submit', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.runAsync(() async {
      authBloc.add(const AuthStatusChecked());
      await authBloc.stream.firstWhere((s) => s.status != AuthStatus.unknown);
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Введите почту'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);
  });

  testWidgets(
    'LoginScreen shows email format error and password length error',
    (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.runAsync(() async {
        authBloc.add(const AuthStatusChecked());
        await authBloc.stream.firstWhere((s) => s.status != AuthStatus.unknown);
      });
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'short');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(find.text('Неверный формат почты'), findsOneWidget);
      expect(
        find.text('Пароль должен содержать минимум 8 символов'),
        findsOneWidget,
      );
    },
  );
}
