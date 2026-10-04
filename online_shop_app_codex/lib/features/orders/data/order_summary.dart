class OrderLineSummary {
  const OrderLineSummary({
    required this.productId,
    required this.quantity,
    required this.variationId,
    this.name = '',
    this.parentName = '',
    this.imageUrl = '',
    this.price = '',
    this.total = '',
    this.options = const {},
  });

  factory OrderLineSummary.fromJson(Map<String, dynamic> json) {
    final image = json['image'];
    final metadata = json['meta_data'];
    final options = <String, String>{};
    if (metadata is List) {
      for (final entry in metadata.whereType<Map>()) {
        final key = (entry['display_key'] ?? entry['key'])?.toString() ?? '';
        final value = entry['display_value'] ?? entry['value'];
        // Internal metadata is not a customer-facing product option.
        if (key.isNotEmpty &&
            !key.startsWith('_') &&
            value is String &&
            value.isNotEmpty) {
          options[key] = value;
        }
      }
    }
    return OrderLineSummary(
      productId: int.tryParse('${json['product_id']}') ?? 0,
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      variationId: int.tryParse('${json['variation_id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      parentName: json['parent_name']?.toString() ?? '',
      imageUrl: image is Map ? image['src']?.toString() ?? '' : '',
      price: json['price']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      options: Map.unmodifiable(options),
    );
  }
  final int productId, quantity, variationId;
  final String name, parentName, imageUrl, price, total;
  final Map<String, String> options;
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.total,
    required this.dateCreated,
    required this.items,
  });
  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    if (id == null || id <= 0) throw const FormatException('Invalid order ID');
    final lines = json['line_items'];
    return OrderSummary(
      id: id,
      status: json['status']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      dateCreated: DateTime.tryParse(json['date_created']?.toString() ?? ''),
      items: List.unmodifiable(
        lines is List
            ? lines.whereType<Map>().map(
                (line) =>
                    OrderLineSummary.fromJson(Map<String, dynamic>.from(line)),
              )
            : <OrderLineSummary>[],
      ),
    );
  }
  final int id;
  final String status, total;
  final DateTime? dateCreated;
  final List<OrderLineSummary> items;
}

class OrdersException implements Exception {
  const OrdersException(this.message);
  final String message;
  @override
  String toString() => message;
}
