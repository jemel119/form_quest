
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signup_app/services/signup_tip_service.dart';
import 'package:signup_app/screens/signup_screen.dart';

class FakeSignupTipService implements SignupTipService {
  final Future<String> Function() response;

  FakeSignupTipService(this.response);

  @override
  Future<String> getTip() => response();
}

Future<void> openSignup(
  WidgetTester tester,
  SignupTipService service,
) async {
  await tester.pumpWidget(
  const MaterialApp(
    home: SignupScreen(),
  ),
);
}

Future<void> enterValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Full Name'),
    'Alex',
  );

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email Address'),
    'alex@example.com',
  );

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    '123456',
  );

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirm Password'),
    '123456',
  );

  await tester.ensureVisible(find.text('Sign Up'));
}

void main() {
  testWidgets('Empty form displays validation errors', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'Use a strong password.'),
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('Invalid email is rejected', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'Use a strong password.'),
    );

    await enterValidForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email Address'),
      'invalid-email',
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('Short password is rejected', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'Use a strong password.'),
    );

    await enterValidForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '12345',
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(
      find.text('Password must be at least 6 characters'),
      findsOneWidget,
    );
  });

  testWidgets('Mismatched passwords block signup', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'Use a strong password.'),
    );

    await enterValidForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      '654321',
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.textContaining('Welcome, Alex!'), findsNothing);
  });

  testWidgets('Valid signup shows personalized success', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'Use a strong password.'),
    );

    await enterValidForm(tester);

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.textContaining('Welcome, Alex!'), findsOneWidget);
  });

  testWidgets('AI tip displays labeled mock advice', (tester) async {
    await openSignup(tester, MockSignupTipService());

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();

    expect(find.text('Getting tip...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('AI-generated advice'), findsOneWidget);
    expect(find.textContaining('mock — no live model called'), findsOneWidget);
  });

  testWidgets('Long AI tip is limited to 240 characters', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => 'A' * 300),
    );

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();
    await tester.pump();

    final text = tester.widget<Text>(
      find.textContaining('AI-generated advice'),
    );

    final displayed = text.data!;

    expect(displayed.split(': ').last.length, 240);
  });

  testWidgets('Empty AI tip shows error and retry', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(() async => '  '),
    );

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Could not get a signup tip'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Offline failure shows error and retry', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(
        () async => throw Exception('Offline'),
      ),
    );

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Could not get a signup tip'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry recovers after a failed request', (tester) async {
    var attempts = 0;

    await openSignup(
      tester,
      FakeSignupTipService(() async {
        attempts++;

        if (attempts == 1) {
          throw Exception('Offline');
        }

        return 'Use a unique password.';
      }),
    );

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);

await tester.ensureVisible(find.text('Retry'));
await tester.pumpAndSettle();

await tester.tap(find.text('Retry'));
await tester.pump();
await tester.pump();

    expect(find.textContaining('Use a unique password.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(attempts, 2);
  });

  testWidgets('AI timeout shows error and retry', (tester) async {
    await openSignup(
      tester,
      FakeSignupTipService(
        () => Completer<String>().future,
      ),
    );

    await tester.ensureVisible(find.text('Get a signup tip'));
    await tester.tap(find.text('Get a signup tip'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 11));

    expect(find.textContaining('Could not get a signup tip'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
