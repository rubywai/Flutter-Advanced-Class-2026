import 'dart:convert';
import 'package:dio/dio.dart';
import 'checkout_models.dart';

class CheckoutService {
  const CheckoutService(this._dio);
  final Dio _dio;

  Future<List<ShippingMethod>> shippingMethods() async {
    try {
      final response = await _dio.get<Object?>(
        '/api.php',
        queryParameters: {'endpoint': 'shipping/zones/2/methods'},
      );
      final data = response.data;
      if (data is! List) {
        throw const CheckoutException('Shipping methods are unavailable.');
      }
      final methods =
          data
              .whereType<Map>()
              .where((m) => m['enabled'] == true)
              .map((m) => ShippingMethod.fromJson(Map<String, dynamic>.from(m)))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      return List.unmodifiable(methods);
    } on DioException catch (error) {
      throw CheckoutException(
        _message(error.response?.data, 'Could not load shipping methods.'),
      );
    }
  }

  Future<OrderResult> createOrder(OrderRequest request) async {
    try {
      final response = await _dio.post<Object?>(
        '/api.php',
        queryParameters: {'endpoint': 'orders'},
        data: request.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      if (response.data is! Map) {
        throw const FormatException('Invalid order response');
      }
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['success'] == false) {
        throw CheckoutException(_message(data, 'Order was rejected.'));
      }
      return OrderResult.fromJson(data);
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      final rejected = code != null && code >= 400 && code < 500;
      throw CheckoutException(
        rejected
            ? _message(
                error.response?.data,
                'Order was rejected. Please review your details.',
              )
            : 'The order result is unknown. It may already have been created. Check with the shop before retrying.',
        uncertain: !rejected,
      );
    } on FormatException {
      throw const CheckoutException(
        'The order response could not be read. It may already have been created. Check with the shop before retrying.',
        uncertain: true,
      );
    }
  }

  String _message(Object? data, String fallback) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return fallback;
      }
    }
    if (data is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final message = data[key];
        if (message is String && message.trim().isNotEmpty) return message;
      }
    }
    return fallback;
  }
}
