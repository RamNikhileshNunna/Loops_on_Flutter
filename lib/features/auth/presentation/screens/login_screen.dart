import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'package:go_router/go_router.dart';

import 'captcha_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _needs2fa = false;

  // Loops expects captcha_type + captcha_token on login.
  static const _captchaType = 'turnstile';
  static const _turnstileSiteKey = '0x4AAAAAAAyXkOaGvV986IOc';

  String? _captchaToken;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _ensureCaptcha() async {
    if (_captchaToken != null && _captchaToken!.isNotEmpty) return;

    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const CaptchaScreen(siteKey: _turnstileSiteKey),
      ),
    );

    if (token != null && token.isNotEmpty) {
      _captchaToken = token;
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);
    try {
      // Loops currently requires captcha_type + captcha_token.
      await _ensureCaptcha();

      final ok = await authRepo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        captchaType: _captchaType,
        captchaToken: _captchaToken,
      );

      setState(() {
        _isLoading = false;
        _needs2fa = !ok;
      });

      if (ok && mounted) context.go('/profile');
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA required. Enter your OTP code.')),
        );
      }
    } catch (e) {
      // If captcha was rejected/expired, clear so next try re-prompts.
      final msg = e.toString().toLowerCase();
      if (msg.contains('captcha')) {
        _captchaToken = null;
      }

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    }
  }

  Future<void> _verify2fa() async {
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final ok = await authRepo.submitTwoFactor(otpCode: _otpController.text.trim());
      setState(() => _isLoading = false);
      if (ok && mounted) context.go('/profile');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('2FA failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign in to loops.video'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            if (_needs2fa) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '2FA OTP code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : (_needs2fa ? _verify2fa : _login),
              child: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_needs2fa ? 'Verify 2FA' : 'Login'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: the official Loops server uses session cookies (Sanctum + CSRF), not OAuth tokens.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
