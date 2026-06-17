import 'package:local_llm_ai_agent/data/models/chat_request_model.dart';
import 'package:local_llm_ai_agent/data/models/response_model.dart';

Messages toMessage(Message message){
  return Messages(
    role: message.role,
    content: message.content,
  );
}