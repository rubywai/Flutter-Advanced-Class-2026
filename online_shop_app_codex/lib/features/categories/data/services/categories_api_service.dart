import 'package:dio/dio.dart';

import '../models/shop_category.dart';

class CategoriesApiService {
  const CategoriesApiService(this._dio);

  final Dio _dio;

  Future<List<ShopCategory>> getCategories({
    int page = 1,
    int perPage = 100,
    int? parent,
    bool hideEmpty = false,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api.php',
      queryParameters: {
        'endpoint': 'products/categories',
        'page': page,
        'per_page': perPage,
        'parent': ?parent,
        'hide_empty': hideEmpty.toString(),
        '_fields':
            'id,name,slug,parent,description,display,image,menu_order,count',
      },
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Missing categories response.');
    }
    return data
        .map((item) => ShopCategory.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
