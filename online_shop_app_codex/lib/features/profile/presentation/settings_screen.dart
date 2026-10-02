import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: auth.isLoading
              ? const CircularProgressIndicator()
              : auth.value?.isAuthenticated == true
              ? _LoggedInProfile(
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                )
              : _LoggedOutProfile(
                  onLogin: () => context.push('/auth/login?redirect=/profile'),
                ),
        ),
      ),
    );
  }
}

class _LoggedOutProfile extends StatelessWidget {
  const _LoggedOutProfile({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.account_circle_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Sign in to your account',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text('Log in to continue to checkout and manage your orders.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onLogin,
          icon: const Icon(Icons.login),
          label: const Text('Log in'),
        ),
      ],
    );
  }
}

class _LoggedInProfile extends StatelessWidget {
  const _LoggedInProfile({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.account_circle, size: 72),
        const SizedBox(height: 16),
        Text(
          'You are logged in',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
