import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malina/features/auth/auth_repository.dart';
import 'package:malina/features/auth/bloc/auth_bloc.dart';
import 'package:malina/features/auth/bloc/auth_state.dart';
import 'package:malina/features/auth/presentation/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAuthBloc extends AuthBloc {
  TestAuthBloc(super.repository);

  void seed(AuthState state) => emit(state);
}

void main() {
  group('LoginPage', () {
    late SharedPreferences prefs;
    late TestAuthBloc authBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authBloc = TestAuthBloc(AuthRepository(prefs));
    });

    tearDown(() async {
      await authBloc.close();
    });

    Future<void> pumpLoginPage(WidgetTester tester) async {
      authBloc.seed(const AuthState(status: AuthStatus.unauthenticated));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const LoginPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('shows validation errors for empty form', (tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите почту'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'admin123');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Неверный формат почты'), findsOneWidget);
    });
  });
}
