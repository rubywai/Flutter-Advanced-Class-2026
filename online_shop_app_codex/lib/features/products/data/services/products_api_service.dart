import 'package:dio/dio.dart';

import '../models/product.dart';

class ProductsApiService {
  const ProductsApiService(this._dio);

  final Dio _dio;

  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 10,
    String orderBy = 'date',
    String order = 'desc',
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api.php',
      queryParameters: {
        'endpoint': 'products',
        'page': page,
        'per_page': perPage,
        'orderby': orderBy,
        'order': order,
      },
    );

    final data = response.data ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }
}
