import 'package:flutter/material.dart';

import '../../data/models/product.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImage(imageUrl: product.imageUrl),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                product.shortDescription.isEmpty
                    ? product.slug
                    : product.shortDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.displayPrice,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          (product.isInStock
                                  ? colorScheme.primary
                                  : colorScheme.error)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        product.isInStock ? 'In stock' : 'Out of stock',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: product.isInStock
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: imageUrl == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}
