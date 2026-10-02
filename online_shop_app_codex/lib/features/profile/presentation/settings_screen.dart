import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../data/models/customer.dart';
import 'customer_edit_screen.dart';
import 'providers/customer_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.value?.isAuthenticated != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: _LoggedOutProfile(
            onLogin: () => context.push('/auth/login?redirect=/profile'),
          ),
        ),
      );
    }
    final customer = ref.watch(customerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: customer.isLoading
                ? null
                : () => ref.read(customerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh profile',
          ),
        ],
      ),
      body: customer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: '$error',
          onRetry: () => ref.invalidate(customerProvider),
        ),
        data: (value) => value == null
            ? const Center(child: Text('Customer information is unavailable.'))
            : _CustomerView(customer: value),
      ),
    );
  }
}

class _CustomerView extends ConsumerWidget {
  const _CustomerView({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = '${customer.firstName} ${customer.lastName}'.trim();
    return RefreshIndicator(
      onRefresh: () => ref.read(customerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (customer.avatarUrl != null && customer.avatarUrl!.isNotEmpty)
            CircleAvatar(
              radius: 38,
              backgroundImage: NetworkImage(customer.avatarUrl!),
            )
          else
            const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name.isEmpty ? customer.username : name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(child: Text(customer.email)),
          if (customer.username.isNotEmpty)
            Center(child: Text('@${customer.username}')),
          const SizedBox(height: 24),
          _section(context, 'Billing address', customer.billing),
          const SizedBox(height: 16),
          _section(context, 'Shipping address', customer.shipping),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CustomerEditScreen(customer: customer),
              ),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Edit profile'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, CustomerAddress address) {
    final lines = [
      '${address.firstName} ${address.lastName}'.trim(),
      address.address1,
      address.address2,
      [
        address.city,
        address.state,
        address.postcode,
      ].where((part) => part.isNotEmpty).join(', '),
      address.country,
      if (address.phone.isNotEmpty) address.phone,
    ].where((line) => line.isNotEmpty).join('\n');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(lines.isEmpty ? 'No address provided.' : lines),
          ],
        ),
      ),
    );
  }
}

class _LoggedOutProfile extends StatelessWidget {
  const _LoggedOutProfile({required this.onLogin});
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) => Column(
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
