
import 'package:local_llm_ai_agent/data/models/response_model.dart';

import '../../const/api_const.dart';
import '../models/chat_request_model.dart';
import 'package:dio/dio.dart';
class LlmChatService {
  final Dio _dio = Dio();
  Future<ResponseModel> sendChat({required ChatRequestModel chatRequestModel}) async{
    final response = await _dio.post(ApiConst.baseUrl,
      options: Options(
        headers: {"Content-Type" : "application/json"},
      ),
      data: chatRequestModel.toJson(),
    );
    return ResponseModel.fromJson(response.data);
  }
}
