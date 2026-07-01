import 'package:flutter/foundation.dart';

import '../data/models/chat_request_model.dart';

class ApiConst {
  ApiConst._();

  static const baseUrl = kIsWeb
      ? "http://localhost:11434/api/chat"
      : "http://10.0.2.2:11434/api/chat";
  static const modelName = "gemma4:e2b";
  static const binancePriceUrl = "https://api.binance.com/api/v3/ticker/price";
  static const systemMessage = {
    "role": "system",
    "content": """
You are a concise assistant.
Please answer Burmese Language.

Tool rule:
When the user asks about drugs, alcohol, politics, war, elections, presidents, governments, or sensitive public conflicts, you MUST call show_warning_dialog first.

The dialog is only a warning UI. It does not block the conversation.

After calling show_warning_dialog, continue answering normally, but keep the answer safe, legal, and responsible.

For normal topics, do not call show_warning_dialog.
For crypto price questions, call get_binance_price when needed.
""",
  };
}
