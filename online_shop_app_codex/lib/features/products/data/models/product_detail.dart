class ProductDetail {
  ProductDetail.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = productPlainText(json['name'] as String? ?? ''),
      price = json['price'] as String? ?? '',
      regularPrice = json['regular_price'] as String? ?? '',
      onSale = json['on_sale'] as bool? ?? false,
      description = productPlainText(json['description'] as String? ?? ''),
      shortDescription = productPlainText(
        json['short_description'] as String? ?? '',
      ),
      type = json['type'] as String? ?? '',
      stockStatus = json['stock_status'] as String? ?? '',
      manageStock = json['manage_stock'] as bool? ?? false,
      stockQuantity = json['stock_quantity'] as int?,
      backordersAllowed = json['backorders_allowed'] as bool? ?? false,
      sku = json['sku'] as String? ?? '',
      averageRating = json['average_rating'] as String? ?? '0',
      ratingCount = json['rating_count'] as int? ?? 0,
      images = List.unmodifiable(
        _objects(json['images']).map(ProductDetailImage.fromJson),
      ),
      categories = List.unmodifiable(
        _objects(json['categories'])
            .map((item) => productPlainText(item['name'] as String? ?? ''))
            .where((name) => name.isNotEmpty),
      ),
      attributes = List.unmodifiable(
        _objects(json['attributes'])
            .where(
              (item) => item['visible'] == true || item['variation'] == true,
            )
            .map(ProductDetailAttribute.fromJson),
      ),
      variationIds = List.unmodifiable(
        (json['variations'] as List? ?? const [])
            .whereType<num>()
            .map((id) => id.toInt())
            .where((id) => id > 0),
      );

  final int id;
  final String name, price, regularPrice, description, shortDescription;
  final String type, stockStatus, sku, averageRating;
  final bool onSale, manageStock, backordersAllowed;
  final int? stockQuantity;
  final int ratingCount;
  final List<ProductDetailImage> images;
  final List<String> categories;
  final List<ProductDetailAttribute> attributes;
  final List<int> variationIds;

  String get displayPrice => price.isEmpty ? 'Price unavailable' : '$price Ks';

  String get availability {
    if (type == 'variable') {
      return 'Select options to check price and availability.';
    }
    if (manageStock) {
      final quantity = stockQuantity;
      if (quantity == null) return 'Stock availability unknown';
      if (quantity > 0) return 'In stock ($quantity available)';
      return backordersAllowed ? 'Available on backorder' : 'Out of stock';
    }
    return switch (stockStatus) {
      'instock' => 'In stock',
      'outofstock' => 'Out of stock',
      'onbackorder' => 'On backorder',
      _ => 'Stock availability unknown',
    };
  }

  static Iterable<Map<String, dynamic>> _objects(dynamic value) =>
      value is List ? value.whereType<Map<String, dynamic>>() : const [];
}

class ProductVariation {
  ProductVariation.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      price = json['price'] as String? ?? '',
      regularPrice = json['regular_price'] as String? ?? '',
      onSale = json['on_sale'] as bool? ?? false,
      stockStatus = json['stock_status'] as String? ?? '',
      manageStock = json['manage_stock'] as bool? ?? false,
      stockQuantity = json['stock_quantity'] as int?,
      backordersAllowed = json['backorders_allowed'] as bool? ?? false,
      attributes = Map.unmodifiable({
        for (final item in ProductDetail._objects(json['attributes']))
          (item['name'] as String? ?? item['slug'] as String? ?? '')
              .trim()
              .toLowerCase(): productPlainText(
            item['option'] as String? ?? '',
          ),
      });

  final int id;
  final String price, regularPrice, stockStatus;
  final bool onSale, manageStock, backordersAllowed;
  final int? stockQuantity;
  final Map<String, String> attributes;

  String get availability {
    if (manageStock) {
      if (stockQuantity == null) return 'Stock availability unknown';
      if (stockQuantity! > 0) return 'In stock ($stockQuantity available)';
      return backordersAllowed ? 'Available on backorder' : 'Out of stock';
    }
    return switch (stockStatus) {
      'instock' => 'In stock',
      'outofstock' =>
        backordersAllowed ? 'Available on backorder' : 'Out of stock',
      'onbackorder' => 'Available on backorder',
      _ => 'Stock availability unknown',
    };
  }

  bool get isAvailable {
    if (manageStock) {
      return (stockQuantity ?? 0) > 0 || backordersAllowed;
    }
    return stockStatus == 'instock' || stockStatus == 'onbackorder';
  }
}

class ProductDetailImage {
  ProductDetailImage.fromJson(Map<String, dynamic> json)
    : url = json['src'] as String? ?? '',
      alt = productPlainText(json['alt'] as String? ?? '');

  final String url, alt;
}

class ProductDetailAttribute {
  ProductDetailAttribute.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int? ?? 0,
      slug = json['slug'] as String? ?? '',
      isVariation = json['variation'] as bool? ?? false,
      name = productPlainText(json['name'] as String? ?? ''),
      options = List.unmodifiable(
        (json['options'] as List? ?? const []).whereType<String>().map(
          productPlainText,
        ),
      );

  final String name;
  final int id;
  final String slug;
  final bool isVariation;
  final List<String> options;

  String get selectionKey => id > 0 ? 'id:$id' : 'name:${name.toLowerCase()}';
}

// Descriptions are displayed as plain text, never executable HTML.
String productPlainText(String html) {
  const entities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'ndash': '-',
    'mdash': '-',
    'lsquo': "'",
    'rsquo': "'",
    'ldquo': '"',
    'rdquo': '"',
    'hellip': '...',
    'bull': '*',
    'copy': '(c)',
    'reg': '(R)',
    'trade': '(TM)',
  };
  return html
      .replaceAll(
        RegExp(
          r'<(script|style)\b[^>]*>[\s\S]*?</\1\s*>',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(
          r'<br\s*/?>|</(?:p|div|h[1-6]|li|ul|ol|tr)\s*>',
          caseSensitive: false,
        ),
        '\n',
      )
      .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '* ')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAllMapped(
        RegExp(r'&(#x[0-9a-fA-F]+|#X[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);'),
        (match) {
          final entity = match[1]!;
          if (!entity.startsWith('#')) return entities[entity] ?? match[0]!;
          final hex = entity.toLowerCase().startsWith('#x');
          final code = int.tryParse(
            entity.substring(hex ? 2 : 1),
            radix: hex ? 16 : 10,
          );
          if (code == null ||
              code <= 0 ||
              code > 0x10ffff ||
              (code >= 0xd800 && code <= 0xdfff)) {
            return match[0]!;
          }
          return String.fromCharCode(code);
        },
      )
      .replaceAll(RegExp(r'[ \t\r]+'), ' ')
      .replaceAll(RegExp(r' *\n *'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
