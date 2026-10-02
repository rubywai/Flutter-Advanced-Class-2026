import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import 'providers/products_providers.dart';
import 'widgets/product_results_view.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Products'),
      actions: [
        IconButton(
          tooltip: 'Search products',
          icon: const Icon(Icons.search),
          onPressed: () => context.pushNamed(AppRoutes.searchName),
        ),
      ],
    ),
    body: const ProductResultsView(query: ProductQuery()),
  );
}
