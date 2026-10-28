import 'package:flutter/material.dart';

import '../services/signup_tip_service.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  final SignupTipService? tipService;

  const SignupScreen({super.key, this.tipService});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 🔑 The Global Key - acts like a remote control for the form
  final _formKey = GlobalKey<FormState>();

  // 📝 Controllers to track what the user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 🎂 Birth-date controller
  final TextEditingController _dateController = TextEditingController();

  late final SignupTipService _tipService;

  bool _isLoading = false;
  String? _tip;
  String? _tipError;

  // 🧪 Activity 11 form enhancements
  bool _obscurePassword = true;
  DateTime? _birthDate;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tipService = widget.tipService ?? MockSignupTipService();
  }

  Future<void> _getSignupTip() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _tip = null;
      _tipError = null;
    });

    try {
      final result = await _tipService.getTip().timeout(
        const Duration(seconds: 10),
      );

      if (result.trim().isEmpty) {
        throw const FormatException('Empty tip');
      }

      if (!mounted) return;

      setState(() {
        _tip = result.trim().substring(
          0,
          result.trim().length > 240 ? 240 : result.trim().length,
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _tipError = 'Could not get a signup tip. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🎂 Open the birth-date picker
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(1920);

    final initialDate =
        _birthDate ?? (DateTime(2008).isAfter(now) ? now : DateTime(2008));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    // Task C: internal guard against double submissions
    if (_submitting) return;

    if (!_formKey.currentState!.validate()) return;

    // Task C: reject whitespace-only names
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() {
      _submitting = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    // Task C: do not navigate after the screen is disposed
    if (!mounted) return;

    // Replace the signup route so Back cannot resubmit the form
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SuccessScreen(userName: name)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👨 Parent
      appBar: AppBar(
        title: const Text('Join Us Today for the Cash Money!'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 👶 Child
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 👤 Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 📧 Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔒 Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔒 Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🎂 Birth Date Field
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                validator: (_) {
                  if (_birthDate == null) {
                    return 'Pick your birth date';
                  }
                  return null;
                },
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 24),

              // 🚀 Sign Up Button
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),

              // AI Signup Coach
              ElevatedButton(
                onPressed: _isLoading ? null : _getSignupTip,
                child: Text(_isLoading ? 'Getting tip...' : 'Get a signup tip'),
              ),
              const SizedBox(height: 12),

              if (_isLoading) const CircularProgressIndicator(),

              if (_tip != null)
                Text(
                  'AI-generated advice (mock — no live model called): $_tip',
                  textAlign: TextAlign.center,
                ),

              if (_tipError != null) ...[
                Text(_tipError!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: _getSignupTip,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
