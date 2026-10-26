
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class SignupTipService {
  Future<String> getTip();
}

class HttpSignupTipService implements SignupTipService {
  final http.Client client;
  final Uri endpoint;

  HttpSignupTipService({
    required this.client,
    required this.endpoint,
  });

  @override
  Future<String> getTip() async {
    if (endpoint.scheme != 'https') {
      throw const FormatException('HTTPS is required');
    }

    final response = await client
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'task': 'signup_tip',
            'topic': 'password_help',
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Tip service unavailable');
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map<String, dynamic> ||
        data['tip'] is! String ||
        (data['tip'] as String).trim().isEmpty) {
      throw const FormatException('Invalid tip response');
    }

    return (data['tip'] as String).trim();
  }
}

class MockSignupTipService implements SignupTipService {
  @override
  Future<String> getTip() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return 'Use a long, unique password for every account.';
  }
}
