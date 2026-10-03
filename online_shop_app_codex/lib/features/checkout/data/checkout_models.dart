import '../../cart/data/models/cart_item.dart';
import '../../profile/data/models/customer.dart';

class ShippingMethod {
  const ShippingMethod(
    this.id,
    this.title,
    this.methodId,
    this.order,
    this.cost,
  );
  final int id, order;
  final String title, methodId;
  final CartMoney? cost;

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    final method = json['method_id']?.toString() ?? '';
    final settings = json['settings'];
    final rawCost = settings is Map ? settings['cost'] : null;
    return ShippingMethod(
      int.tryParse('${json['instance_id'] ?? json['id']}') ?? 0,
      json['title']?.toString() ?? '',
      method,
      int.tryParse('${json['order']}') ?? 0,
      method == 'free_shipping'
          ? CartMoney.zero
          : method == 'flat_rate' && rawCost is Map
          ? CartMoney.tryParse('${rawCost['value']}')
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'method_id': methodId,
    'method_title': title,
    'total': cost.toString(),
  };
}

class OrderRequest {
  OrderRequest({
    required List<CartItem> items,
    required this.billing,
    required this.shipping,
    required this.method,
    required this.note,
  }) : items = List.unmodifiable(items);
  final List<CartItem> items;
  final CustomerAddress billing, shipping;
  final ShippingMethod method;
  final String note;

  Map<String, dynamic> toJson() => {
    'payment_method': 'cod',
    'payment_method_title': 'Cash on Delivery',
    'set_paid': false,
    'billing': billing.toJson(),
    'shipping': shipping.toShippingJson(),
    'line_items': [
      for (final item in items)
        {
          'product_id': item.productId,
          'quantity': item.quantity,
          if (item.variationId != 0) 'variation_id': item.variationId,
        },
    ],
    'shipping_lines': [method.toJson()],
    'customer_note': note,
  };
}

class OrderResult {
  const OrderResult({
    required this.id,
    required this.status,
    required this.currency,
    required this.total,
    required this.subtotal,
    required this.shippingTotal,
  });
  final int id;
  final String status, currency, total, subtotal, shippingTotal;

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    if (id == null || id <= 0) throw const FormatException('Missing order ID');
    String text(String key) => json[key]?.toString() ?? '';
    return OrderResult(
      id: id,
      status: text('status'),
      currency: text('currency'),
      total: text('total'),
      subtotal: text('subtotal'),
      shippingTotal: text('shipping_total'),
    );
  }
}

class CheckoutException implements Exception {
  const CheckoutException(this.message, {this.uncertain = false});
  final String message;
  final bool uncertain;
  @override
  String toString() => message;
}
