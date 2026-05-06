import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:malina/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App smoke tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('app launches and shows login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Малина'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
    });
  });
}
