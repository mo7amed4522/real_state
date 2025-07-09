import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_state_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Screens Integration Test', () {
    testWidgets('LoginScreen UI loads and basic interaction', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Find Login button or text field (adjust keys as needed)
      final loginEmailField = find.byKey(const Key('login_email'));
      final loginPasswordField = find.byKey(const Key('login_password'));
      final loginButton = find.byKey(const Key('login_button'));

      expect(loginEmailField, findsOneWidget);
      expect(loginPasswordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Enter text and tap login
      await tester.enterText(loginEmailField, 'test@example.com');
      await tester.enterText(loginPasswordField, 'password123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
    });

    testWidgets('RegisterScreen UI loads and basic interaction', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to register screen (adjust navigation as needed)
      final goToRegisterButton = find.byKey(const Key('go_to_register'));
      await tester.tap(goToRegisterButton);
      await tester.pumpAndSettle();

      final registerEmailField = find.byKey(const Key('register_email'));
      final registerPasswordField = find.byKey(const Key('register_password'));
      final registerButton = find.byKey(const Key('register_button'));

      expect(registerEmailField, findsOneWidget);
      expect(registerPasswordField, findsOneWidget);
      expect(registerButton, findsOneWidget);

      // Enter text and tap register
      await tester.enterText(registerEmailField, 'newuser@example.com');
      await tester.enterText(registerPasswordField, 'newpassword123');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();
    });
  });
}
