import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final productId = 'product-${index + 1}';

          return Card(
            child: ListTile(
              title: Text('Product ${index + 1}'),
              subtitle: const Text('API-backed data will replace this item.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/products/$productId'),
            ),
          );
        },
      ),
    );
  }
}
