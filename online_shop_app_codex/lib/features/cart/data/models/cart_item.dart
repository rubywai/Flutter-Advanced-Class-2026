import 'dart:convert';

import '../../../products/data/models/product_detail.dart';

class CartException implements Exception {
  const CartException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CartMoney {
  const CartMoney._(this.coefficient, this.scale);
  final BigInt coefficient;
  final int scale;

  static CartMoney? tryParse(String value) {
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) return null;
    final parts = value.split('.');
    return CartMoney._(
      BigInt.parse(parts.join()),
      parts.length == 2 ? parts[1].length : 0,
    );
  }

  static final zero = CartMoney._(BigInt.zero, 0);
  CartMoney operator +(CartMoney other) {
    final digits = scale > other.scale ? scale : other.scale;
    return CartMoney._(
      coefficient * BigInt.from(10).pow(digits - scale) +
          other.coefficient * BigInt.from(10).pow(digits - other.scale),
      digits,
    );
  }

  CartMoney times(int quantity) =>
      CartMoney._(coefficient * BigInt.from(quantity), scale);
  @override
  String toString() {
    if (scale == 0) return coefficient.toString();
    final digits = coefficient.toString().padLeft(scale + 1, '0');
    return '${digits.substring(0, digits.length - scale)}.${digits.substring(digits.length - scale)}';
  }
}

class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.manageStock,
    required this.stockQuantity,
    required this.stockStatus,
    required this.backordersAllowed,
    this.variationId = 0,
    this.options = const {},
  });

  factory CartItem.fromProduct(
    ProductDetail product,
    int quantity, {
    ProductVariation? variation,
    Map<String, String> options = const {},
  }) => CartItem(
    productId: product.id,
    variationId: variation?.id ?? 0,
    options: Map.unmodifiable(options),
    name: product.name,
    imageUrl: product.images.isEmpty ? '' : product.images.first.url,
    price: variation?.price ?? product.price,
    quantity: quantity,
    manageStock: variation?.manageStock ?? product.manageStock,
    stockQuantity: variation?.stockQuantity ?? product.stockQuantity,
    stockStatus: variation?.stockStatus ?? product.stockStatus,
    backordersAllowed:
        variation?.backordersAllowed ?? product.backordersAllowed,
  );

  factory CartItem.fromRow(Map<String, Object?> row) => CartItem(
    productId: row['product_id'] as int,
    variationId: row['variation_id'] as int? ?? 0,
    options: Map.unmodifiable(
      (jsonDecode(row['options_json'] as String? ?? '{}')
              as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as String)),
    ),
    name: row['name'] as String,
    imageUrl: row['image_url'] as String,
    price: row['price'] as String,
    quantity: row['quantity'] as int,
    manageStock: row['manage_stock'] == 1,
    stockQuantity: row['stock_quantity'] as int?,
    stockStatus: row['stock_status'] as String,
    backordersAllowed: row['backorders_allowed'] == 1,
  );

  final int productId, quantity;
  final int variationId;
  final Map<String, String> options;
  final String name, imageUrl, price, stockStatus;
  final bool manageStock, backordersAllowed;
  final int? stockQuantity;
  CartMoney get unitPrice => CartMoney.tryParse(price)!;
  CartMoney get total => unitPrice.times(quantity);

  bool permits(int value) {
    if (value < 1 || value > 2147483647) return false;
    if (manageStock) {
      if (stockQuantity == null) return false;
      return backordersAllowed || value <= stockQuantity!;
    }
    return stockStatus == 'instock' || stockStatus == 'onbackorder';
  }

  Map<String, Object?> toRow() => {
    'product_id': productId,
    'variation_id': variationId,
    'options_json': jsonEncode(options),
    'name': name,
    'image_url': imageUrl,
    'price': price,
    'quantity': quantity,
    'manage_stock': manageStock ? 1 : 0,
    'stock_quantity': stockQuantity,
    'stock_status': stockStatus,
    'backorders_allowed': backordersAllowed ? 1 : 0,
  };

  static String? unavailableReason(ProductDetail product) =>
      CartMoney.tryParse(product.price) == null ? 'Price unavailable.' : null;
}
