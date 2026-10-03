import 'dart:convert';
import 'package:dio/dio.dart';
import 'order_summary.dart';

class OrdersService {
  const OrdersService(this._dio);
  final Dio _dio;

  Future<List<OrderSummary>> getOrders(
    int customerId, {
    CancelToken? cancelToken,
    String? status,
  }) async {
    if (customerId <= 0) {
      throw const OrdersException('Please log in again to load your orders.');
    }
    try {
      final response = await _dio.get<Object?>(
        '/api.php',
        queryParameters: {
          'endpoint': 'orders',
          'customer': customerId.toString(),
          'status': ?status,
          '_fields': 'id,status,total,date_created,line_items',
        },
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is! List) {
        throw const OrdersException('The order list could not be read.');
      }
      final orders =
          data.map((value) {
            if (value is! Map) throw const FormatException('Invalid order');
            return OrderSummary.fromJson(Map<String, dynamic>.from(value));
          }).toList()..sort((a, b) {
            final date = (b.dateCreated ?? DateTime(1970)).compareTo(
              a.dateCreated ?? DateTime(1970),
            );
            return date != 0 ? date : b.id.compareTo(a.id);
          });
      return List.unmodifiable(orders);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        throw const OrdersException(
          'Your session is invalid. Log out and log in again to load your orders.',
        );
      }
      throw OrdersException(_message(error.response?.data));
    } on FormatException {
      throw const OrdersException('The order list could not be read.');
    }
  }

  String _message(Object? data) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return 'Could not load orders. Please try again.';
      }
    }
    if (data is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return 'Could not load orders. Please try again.';
  }
}
