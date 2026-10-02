import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/shop_category.dart';
import '../../data/services/categories_api_service.dart';

final categoriesApiServiceProvider = Provider<CategoriesApiService>((ref) {
  return CategoriesApiService(ref.watch(dioProvider));
});

final categoriesProvider = FutureProvider.autoDispose<List<CategoryListEntry>>((
  ref,
) async {
  final service = ref.watch(categoriesApiServiceProvider);
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  const perPage = 100;
  final categories = <int, ShopCategory>{};
  for (var page = 1; ; page++) {
    final batch = await service.getCategories(
      page: page,
      perPage: perPage,
      cancelToken: cancelToken,
    );
    final previousCount = categories.length;
    for (final category in batch) {
      categories[category.id] = category;
    }
    if (batch.length < perPage) break;
    // Fail instead of looping forever if the server ignores pagination.
    if (categories.length == previousCount) {
      throw const FormatException('Category pagination did not advance.');
    }
  }

  final sorted = categories.values.toList()
    ..sort((a, b) {
      final order = a.menuOrder.compareTo(b.menuOrder);
      return order != 0 ? order : a.name.compareTo(b.name);
    });
  final children = <int, List<ShopCategory>>{};
  for (final category in sorted) {
    children.putIfAbsent(category.parent, () => []).add(category);
  }
  final entries = <CategoryListEntry>[];
  final visited = <int>{};
  void visit(ShopCategory category, List<String> ancestors) {
    if (!visited.add(category.id)) return;
    entries.add(CategoryListEntry(category, ancestors.join(' / ')));
    for (final child in children[category.id] ?? <ShopCategory>[]) {
      visit(child, [...ancestors, category.name]);
    }
  }

  for (final category in sorted) {
    if (category.parent == 0 || !categories.containsKey(category.parent)) {
      visit(category, []);
    }
  }
  // Keep malformed cyclic hierarchies visible without infinite traversal.
  for (final category in sorted) {
    visit(category, []);
  }
  return List.unmodifiable(entries);
});

class CategoryListEntry {
  const CategoryListEntry(this.category, this.parentPath);

  final ShopCategory category;
  final String parentPath;
}
