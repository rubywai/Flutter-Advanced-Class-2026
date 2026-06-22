import 'package:flutter/foundation.dart';

import '../data/models/chat_request_model.dart';

class ApiConst {
  ApiConst._();

  static const baseUrl = kIsWeb
      ? "http://localhost:11434/api/chat"
      : "http://10.0.2.2:11434/api/chat";
  static const modelName = "gemma4:e2b";
  static const systemMessage = {
    "role": "system",
    "content": "You are a concise assistant. Alcohol-related topics are allowed only for legal, safe, and responsible discussion. Political topics are not allowed. If the user asks about politics, refuse briefly and redirect to a non-political topic. You may use tools when needed.",
  };
  static List<Tools> systemTools = [
    Tools(
      type: "function",
      function: FunctionTools(
        name: "show_warning_dialog",
        description:
            "Display a dialog to the user with a warning title and content message if users is asking about drugs, alcohol",
        parameters: Parameters(
          type: "object",
          properties: Properties(
            title: Title(
              type: "string",
              description: "The title of the warning dialog",
            ),
            content: Content(
              type: "string",
              description: "Dialog content/message",
            ),
          ),
          required: ["title", "content"],
          additionalProperties: false,
        ),
      ),
    ),
  ];
}
