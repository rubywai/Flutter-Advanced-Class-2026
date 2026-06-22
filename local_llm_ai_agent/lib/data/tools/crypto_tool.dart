import 'package:dio/dio.dart';

const cryptoTool = {
  "type": "function",
  "function": {
    "name": "getCrypto",
    "description":
        "Get the current price of a cryptocurrency in USD. Use this whenever the user asks about the price or value of a coin.",
    "parameters": {
      "type": "object",
      "properties": {
        "coin": {
          "type": "string",
          "description":
              "The CoinGecko coin id in lowercase, e.g. bitcoin, ethereum, dogecoin, solana",
        },
      },
      "required": ["coin"],
    },
  },
};

Future<String> executeTool(String? name, Map<String, dynamic> args) async {
  switch (name) {
    case "getCrypto":
      return getCrypto(args);
    default:
      return 'Unknown tool: $name';
  }
}

Future<String> getCrypto(Map<String, dynamic> args) async {
  final coin = (args['coin'] ?? '').toString().toLowerCase().trim();
  if (coin.isEmpty) return 'No coin specified.';
  try {
    final response = await Dio().get(
      'https://api.coingecko.com/api/v3/simple/price',
      queryParameters: {'ids': coin, 'vs_currencies': 'usd'},
    );
    final price = response.data[coin]?['usd'];
    if (price == null) return 'Could not find a price for "$coin".';
    return '$coin is currently \$$price USD.';
  } catch (e) {
    return 'Failed to fetch price for "$coin": $e';
  }
}
