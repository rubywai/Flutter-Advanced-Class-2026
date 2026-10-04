import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/customer.dart';

class CustomerService {
  const CustomerService(this._dio);
  final Dio _dio;

  Future<Customer> getCustomer(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api.php',
        queryParameters: {'endpoint': 'customers/$id'},
      );
      final data = _customerMap(response.data);
      if (data == null) {
        throw const CustomerException('Customer data is missing.');
      }
      return Customer.fromJson(data);
    } on DioException catch (error) {
      throw CustomerException(_message(error.response?.data));
    }
  }

  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api.php',
        queryParameters: {'endpoint': 'customers/${customer.id}'},
        data: customer.toUpdateJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      final data = _customerMap(response.data);
      if (data == null) {
        throw const CustomerException('Customer data is missing.');
      }
      return Customer.fromJson(data);
    } on DioException catch (error) {
      throw CustomerException(_message(error.response?.data));
    }
  }

  Map<String, dynamic>? _customerMap(Object? value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final nested = map['data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return map.containsKey('id') ? map : null;
  }

  String _message(Object? value) {
    Object? decoded = value;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {
        final text = value as String;
        return text.trim().isEmpty ? 'Request failed.' : text;
      }
    }
    if (decoded is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final message = decoded[key];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      if (decoded['data'] != null) return _message(decoded['data']);
    }
    return 'Unable to load customer information.';
  }
}

class CustomerException implements Exception {
  const CustomerException(this.message);
  final String message;
  @override
  String toString() => message;
}
