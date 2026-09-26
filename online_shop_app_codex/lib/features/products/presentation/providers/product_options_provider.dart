import 'package:flutter_riverpod/flutter_riverpod.dart';

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
