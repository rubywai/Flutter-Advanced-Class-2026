import 'package:flutter/material.dart';

import '../../products/presentation/providers/products_providers.dart';
import '../../products/presentation/widgets/product_results_view.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  final int categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final name = categoryName?.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name == null || name.isEmpty ? 'Products' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: categoryId <= 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48),
                    SizedBox(height: 16),
                    Text('Invalid category.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ProductResultsView(
              query: ProductQuery(categoryId: categoryId, perPage: 20),
            ),
    );
  }
}
