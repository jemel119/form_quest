import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/screens/signup_screen.dart';
import 'package:signup_app/screens/success_screen.dart';
import 'package:signup_app/screens/welcome_screen.dart';

void main() {
  Future<void> enterValidSignup(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    await tester.tap(find.text('Enter If You Dare'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Test Guest',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email Address'),
      'guest@example.com',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      'password123',
    );

    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Birth Date'),
    );

    await tester.tap(find.widgetWithText(TextFormField, 'Birth Date'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('Empty name redirects from Success to Welcome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SuccessScreen(userName: '')),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Welcome, !'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Double submission creates only one Success screen', (
    WidgetTester tester,
  ) async {
    await enterValidSignup(tester);

    final signupButton = find.text('Sign Up');

    await tester.ensureVisible(signupButton);

    await tester.tap(signupButton);

    // The internal guard must reject repeated submissions.
    await tester.tap(find.byType(ElevatedButton).first, warnIfMissed: false);

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byType(SuccessScreen), findsOneWidget);
    expect(find.text('Welcome, Test Guest!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Leaving during loading does not navigate afterward', (
    WidgetTester tester,
  ) async {
    await enterValidSignup(tester);

    final signupButton = find.text('Sign Up');

    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Leave before the simulated submission completes.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(SuccessScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
