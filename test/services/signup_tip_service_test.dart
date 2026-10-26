
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:signup_app/services/signup_tip_service.dart';

void main() {
  final endpoint = Uri.parse('https://example.com/signup-tip');

  test('Mock returns a deterministic signup tip', () async {
    final service = MockSignupTipService();

    final tip = await service.getTip();

    expect(tip, 'Use a long, unique password for every account.');
  });

  test('HTTP success returns a valid tip', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, endpoint);

      return http.Response(
        jsonEncode({'tip': 'Choose a unique password.'}),
        200,
      );
    });

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    expect(await service.getTip(), 'Choose a unique password.');
    client.close();
  });

  test('Privacy boundary sends only fixed task and topic', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.scheme, 'https');
      expect(request.headers['content-type'], contains('application/json'));

      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body, {
        'task': 'signup_tip',
        'topic': 'password_help',
      });

      expect(body.containsKey('name'), false);
      expect(body.containsKey('email'), false);
      expect(body.containsKey('password'), false);
      expect(body.containsKey('confirmPassword'), false);

      return http.Response(
        jsonEncode({'tip': 'Use a unique password.'}),
        200,
      );
    });

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await service.getTip();
    client.close();
  });

  test('Non-200 response throws an error', () async {
    final client = MockClient(
      (request) async => http.Response('Unavailable', 503),
    );

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await expectLater(service.getTip(), throwsException);
    client.close();
  });

  test('Malformed JSON throws an error', () async {
    final client = MockClient(
      (request) async => http.Response('{invalid json', 200),
    );

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await expectLater(service.getTip(), throwsFormatException);
    client.close();
  });

  test('Empty tip throws an error', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({'tip': '   '}),
        200,
      ),
    );

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await expectLater(service.getTip(), throwsFormatException);
    client.close();
  });

  test('Offline request throws an error', () async {
    final client = MockClient(
      (request) async => throw Exception('Network unavailable'),
    );

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await expectLater(service.getTip(), throwsException);
    client.close();
  });

  test('Timeout throws TimeoutException', () async {
    final client = MockClient((request) async {
      return Completer<http.Response>().future;
    });

    final service = HttpSignupTipService(
      client: client,
      endpoint: endpoint,
    );

    await expectLater(
      service.getTip(),
      throwsA(isA<TimeoutException>()),
    );

    client.close();
  }, timeout: const Timeout(Duration(seconds: 15)));

  test('Non-HTTPS endpoint is rejected', () async {
    final service = HttpSignupTipService(
      client: MockClient(
        (request) async => http.Response('{}', 200),
      ),
      endpoint: Uri.parse('http://example.com/signup-tip'),
    );

    await expectLater(service.getTip(), throwsFormatException);
  });
}
