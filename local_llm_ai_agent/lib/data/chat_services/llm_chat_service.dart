import 'dart:convert';

import 'package:local_llm_ai_agent/data/models/response_model.dart';

import '../../const/api_const.dart';
import '../models/chat_request_model.dart';
import 'package:dio/dio.dart';

class LlmChatService {
  final Dio _dio = Dio();

  Future<ResponseModel> sendChat({
    required ChatRequestModel chatRequestModel,
  }) async {
    final response = await _dio.post(
      ApiConst.baseUrl,
      options: Options(headers: {"Content-Type": "application/json"}),
      data: chatRequestModel.toJson(),
    );
    return ResponseModel.fromJson(response.data);
  }

  Stream<ResponseModel> sendChatStream({
    required ChatRequestModel chatRequestModel,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      ApiConst.baseUrl,
      options: Options(
        headers: {"Content-Type": "application/json"},
        responseType: ResponseType.stream,
      ),
      data: chatRequestModel.toJson(),
    );

    final lines = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(LineSplitter());
    await for (String line in lines) {
      if (line.trim().isEmpty) continue;
      yield ResponseModel.fromJson(jsonDecode(line));
    }
  }
}
