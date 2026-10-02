import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_detail.dart';
import '../providers/product_options_provider.dart';

class ProductOptionChooser extends ConsumerWidget {
  const ProductOptionChooser({super.key, required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = product.attributes
        .where((item) => item.isVariation)
        .toList();
    final provider = productOptionsProvider(product.id);
    final selected = ref.watch(provider);
    final complete =
        attributes.isNotEmpty &&
        attributes.every(
          (attribute) =>
              attribute.options.contains(selected[attribute.selectionKey]),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final attribute in attributes) ...[
          const SizedBox(height: 16),
          Text(attribute.name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (attribute.options.isEmpty)
            const Text('Options unavailable')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in attribute.options.toSet())
                  ChoiceChip(
                    label: Text(option),
                    avatar: _colorSwatch(attribute, option),
                    selected: selected[attribute.selectionKey] == option,
                    onSelected: (_) => ref
                        .read(provider.notifier)
                        .select(attribute.selectionKey, option),
                  ),
              ],
            ),
        ],
        if (complete) ...[
          const SizedBox(height: 16),
          Text(
            attributes
                .map(
                  (attribute) =>
                      '${attribute.name}: ${selected[attribute.selectionKey]}',
                )
                .join(' / '),
          ),
        ],
      ],
    );
  }

  Widget? _colorSwatch(ProductDetailAttribute attribute, String option) {
    if (!{
          'color',
          'colour',
          'pa_color',
          'pa_colour',
        }.contains(attribute.name.toLowerCase()) &&
        !{'pa_color', 'pa_colour'}.contains(attribute.slug)) {
      return null;
    }
    const colors = <String, Color>{
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'brown': Colors.brown,
    };
    final color = colors[option.toLowerCase().trim()];
    if (color == null) return null;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
    );
  }
}
