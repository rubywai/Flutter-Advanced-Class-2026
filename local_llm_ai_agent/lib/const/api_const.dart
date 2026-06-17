class ApiConst {
  ApiConst._();
  static const baseUrl = "http://10.0.2.2:11434/api/chat";
  static const modelName = "gemma4:e2b";
  static const systemMessage = {
    "role": "system",
    "content": "You are a concise assistant.Please answer in detail and clear"
  };
}