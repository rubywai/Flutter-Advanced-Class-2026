import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/categories_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Category')),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            ref.invalidate(categoriesProvider);
            await ref.read(categoriesProvider.future);
          } catch (_) {
            // The provider exposes refresh failures through the error view.
          }
        },
        child: categories.when(
          skipLoadingOnRefresh: false,
          loading: () => const _StateView(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _StateView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Could not load categories.'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return const _StateView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_outlined, size: 48),
                    SizedBox(height: 16),
                    Text('No categories found.'),
                  ],
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final category = entry.category;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryImage(
                        url: category.image?.src,
                        alt: category.image?.alt,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (entry.parentPath.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                entry.parentPath,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              '${category.count} ${category.count == 1 ? 'product' : 'products'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({this.url, this.alt});

  final String? url;
  final String? alt;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.category_outlined, size: 28)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 64,
        child: url == null || url!.trim().isEmpty
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                semanticLabel: alt?.isNotEmpty == true ? alt : null,
                excludeFromSemantics: alt?.isNotEmpty != true,
                errorBuilder: (context, error, stackTrace) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: child),
          ),
        ),
      ],
    );
  }
}
