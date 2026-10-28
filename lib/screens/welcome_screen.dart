import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E1065),
              Color(0xFF14101F),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '\u{1F987}',
                style: TextStyle(fontSize: 72),
              ),

              // Letters appear one by one — typewriter spell
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'The Haunted Mansion',
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 120),
                  ),
                ],
                totalRepeatCount: 1,
              ),

              const SizedBox(height: 12),

              const Text(
                'Sign the guest book… if you dare.',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // push() = the user can walk back out the front door
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text('Enter If You Dare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}