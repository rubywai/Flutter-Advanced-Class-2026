import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Shop')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Shop by feature',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _HomeActionCard(
            title: 'Products',
            subtitle: 'Browse catalog items',
            icon: Icons.storefront_outlined,
            onTap: () => context.go(AppRoutes.products),
          ),
          const SizedBox(height: 12),
          _HomeActionCard(
            title: 'Cart',
            subtitle: 'Review selected products',
            icon: Icons.shopping_cart_outlined,
            onTap: () => context.go(AppRoutes.cart),
          ),
          const SizedBox(height: 12),
          _HomeActionCard(
            title: 'Profile',
            subtitle: 'Manage account details',
            icon: Icons.person_outline,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
