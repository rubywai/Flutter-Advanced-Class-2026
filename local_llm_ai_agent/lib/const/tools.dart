import '../data/models/chat_request_model.dart';

class AppTools{
  static List<Tools> systemTools = [
    Tools(
      type: "function",
      function: FunctionTools(
        name: "show_warning_dialog",
        description:
        "Show a warning dialog when the user asks about drugs, alcohol, politics, war, elections, presidents, governments, or sensitive public conflicts. This dialog is only a warning and does not block the conversation",
        parameters: Parameters(
          type: "object",
          properties: {
            "title": {
              "type": "string",
              "description": "The title of the warning dialog",
            },
            "content": {
              "type": "string",
              "description": "Dialog content/message",
            },
          },
          required: ["title", "content"],
          additionalProperties: false,
        ),
      ),
    ),
    Tools(
      type: "function",
      function: FunctionTools(
        name: "get_binance_price",
        description:
        "Get the latest cryptocurrency price from Binance by trading pair symbol, for example BTCUSDT, ETHUSDT, or BNBUSDT",
        parameters: Parameters(
          type: "object",
          properties: {
            "symbol": {
              "type": "string",
              "description":
              "Binance trading pair symbol in uppercase, for example BTCUSDT, ETHUSDT, SOLUSDT. Please answer in human readable format like comma and unit",
            },
          },
          required: ["symbol"],
          additionalProperties: false,
        ),
      ),
    ),
  ];
}