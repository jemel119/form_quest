import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'welcome_screen.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();

    // Task C: never display a success screen with an empty name
    if (widget.userName.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      });
      return;
    }

    // 🎉 Fire the confetti once when the guest arrives
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Task C: guard against invalid navigation arguments
    if (widget.userName.trim().isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\u{1F383}',
                  style: TextStyle(fontSize: 72),
                ),

                Text(
                  'Welcome, ${widget.userName}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Your haunted guest pass is confirmed.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Back to the Foyer'),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
            ),
          ),
        ],
      ),
    );
  }
}