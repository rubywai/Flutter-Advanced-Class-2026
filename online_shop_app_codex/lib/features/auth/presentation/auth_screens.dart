import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirect});
  final String? redirect;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!email.text.contains('@') || password.text.length < 6) {
      setState(() => error = 'Enter a valid email and password.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .login(email: email.text.trim(), password: password.text);
      if (mounted) context.go(widget.redirect ?? '/');
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Log in',
    error: error,
    children: [
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : submit,
        child: Text(busy ? 'Logging in…' : 'Log in'),
      ),
      TextButton(
        onPressed: () => context.push('/auth/register'),
        child: const Text('Create an account'),
      ),
      TextButton(
        onPressed: () => context.push('/auth/reset'),
        child: const Text('Forgot password?'),
      ),
    ],
  );
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.redirect});
  final String? redirect;
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController(),
      username = TextEditingController(),
      confirm = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    for (final c in [email, password, name, username, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty ||
        !email.text.contains('@') ||
        password.text.length < 6 ||
        name.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text != confirm.text) {
      setState(
        () => error = 'Complete all fields and make sure passwords match.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .register(
            email: email.text.trim(),
            password: password.text,
            displayName: name.text.trim(),
            userLogin: username.text.trim(),
          );
      if (mounted) {
        context.push(
          '/auth/verify',
          extra: {'email': email.text.trim(), 'redirect': widget.redirect},
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Create account',
    error: error,
    children: [
      TextField(
        controller: name,
        decoration: const InputDecoration(labelText: 'Display name'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: username,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: confirm,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Confirm password'),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : submit,
        child: Text(busy ? 'Creating…' : 'Sign up'),
      ),
      TextButton(
        onPressed: () => context.go('/auth/login'),
        child: const Text('Already have an account? Log in'),
      ),
    ],
  );
}

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.email, this.redirect});
  final String email;
  final String? redirect;
  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final otp = TextEditingController();
  bool busy = false;
  String? error;
  Future<void> submit() async {
    if (otp.text.trim().length < 4) {
      setState(() => error = 'Enter the verification code.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .verify(email: widget.email, otp: otp.text.trim());
      if (mounted) {
        context.go(
          '/auth/login?verified=1${widget.redirect == null ? '' : '&redirect=${Uri.encodeComponent(widget.redirect!)}'}',
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Verify email',
    error: error,
    children: [
      Text('Enter the code sent to ${widget.email}'),
      const SizedBox(height: 16),
      TextField(
        controller: otp,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'OTP'),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : submit,
        child: Text(busy ? 'Verifying…' : 'Verify'),
      ),
    ],
  );
}

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});
  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final email = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!email.text.contains('@')) {
      setState(() => error = 'Enter a valid email.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await ref
          .read(authServiceProvider)
          .reset(email.text.trim());
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset link sent'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
    title: 'Reset password',
    error: error,
    children: [
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : submit,
        child: Text(busy ? 'Sending…' : 'Send reset link'),
      ),
      TextButton(
        onPressed: () => context.go('/auth/login'),
        child: const Text('Back to login'),
      ),
    ],
  );
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.children,
    this.error,
  });
  final String title;
  final List<Widget> children;
  final String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}
