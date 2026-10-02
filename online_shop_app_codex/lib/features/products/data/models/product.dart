class Product {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.shortDescription,
    required this.stockStatus,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String slug;
  final String price;
  final String shortDescription;
  final String stockStatus;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final firstImage = images is List && images.isNotEmpty
        ? images.first
        : null;

    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: json['price'] as String? ?? '',
      shortDescription: _stripHtml(json['short_description'] as String? ?? ''),
      stockStatus: json['stock_status'] as String? ?? '',
      imageUrl: firstImage is Map<String, dynamic>
          ? (firstImage['thumbnail'] as String? ?? firstImage['src'] as String?)
          : null,
    );
  }

  String get displayPrice => price.isEmpty ? 'Price unavailable' : '$price Ks';

  bool get isInStock => stockStatus == 'instock';

  static String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
}
