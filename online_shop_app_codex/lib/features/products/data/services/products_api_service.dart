import 'package:dio/dio.dart';

import '../models/product.dart';
import '../models/product_detail.dart';

class ProductsApiService {
  const ProductsApiService(this._dio);

  final Dio _dio;

  Future<ProductDetail> getProduct(
    String id, {
    CancelToken? cancelToken,
  }) async {
    final productId = int.tryParse(id);
    if (productId == null || productId <= 0) {
      throw const FormatException('Invalid product ID');
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/api.php',
      queryParameters: {
        'endpoint': 'products/$productId',
        '_fields':
            'id,name,price,regular_price,on_sale,description,short_description,type,stock_status,manage_stock,stock_quantity,backorders_allowed,sku,average_rating,rating_count,images,categories,attributes',
      },
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null || data['id'] != productId) {
      throw const FormatException('Invalid product response');
    }
    return ProductDetail.fromJson(data);
  }

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
