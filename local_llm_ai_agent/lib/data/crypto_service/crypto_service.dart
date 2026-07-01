import 'package:dio/dio.dart';

import '../../const/api_const.dart';
import '../models/crypto_response_model.dart';

class CryptoService {
  final Dio _dio = Dio();

  Future<CryptoResponseModel> getCryptoPrice(String symbol) async {
    final response = await _dio.get('${ApiConst.binancePriceUrl}?symbol=$symbol');
    return CryptoResponseModel.fromJson(response.data);
  }
}
