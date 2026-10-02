import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../data/models/product_detail.dart';
import 'products_providers.dart';

final productOptionsProvider = NotifierProvider.autoDispose
    .family<ProductOptionsNotifier, Map<String, String>, int>(
      ProductOptionsNotifier.new,
    );

class ProductOptionsNotifier extends Notifier<Map<String, String>> {
  ProductOptionsNotifier(this.productId);

  final int productId;

  @override
  Map<String, String> build() => const {};

  void select(String attribute, String option) {
    state = Map.unmodifiable({...state, attribute: option});
  }
}

final productVariationProvider = FutureProvider.autoDispose
    .family<ProductVariation?, ProductVariationQuery>((ref, query) async {
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final service = ref.read(productsApiServiceProvider);
      for (final id in query.variationIds) {
        final variation = await service.getVariation(
          id,
          cancelToken: cancelToken,
        );
        if (variation.attributes.length != query.options.length) continue;
        final matches = query.options.entries.every(
          (entry) =>
              variation.attributes[entry.key]?.trim().toLowerCase() ==
              entry.value.trim().toLowerCase(),
        );
        if (matches) return variation;
      }
      return null;
    });

class ProductVariationQuery {
  ProductVariationQuery({
    required this.variationIds,
    required Map<String, String> options,
  }) : options = Map.unmodifiable({
         for (final entry in options.entries)
           entry.key.trim().toLowerCase(): entry.value,
       });

  final List<int> variationIds;
  final Map<String, String> options;

  @override
  bool operator ==(Object other) =>
      other is ProductVariationQuery && _key == other._key;

  String get _key =>
      '${variationIds.join(',')}|${(options.entries.toList()..sort((a, b) => a.key.compareTo(b.key))).map((e) => '${e.key}:${e.value}').join('|')}';

  @override
  int get hashCode => _key.hashCode;
}
