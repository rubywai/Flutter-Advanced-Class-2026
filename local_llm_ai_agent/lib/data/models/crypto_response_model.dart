class CryptoResponseModel {
  CryptoResponseModel({this.symbol, this.price});

  CryptoResponseModel.fromJson(dynamic json) {
    symbol = json['symbol'];
    price = json['price'];
  }

  String? symbol;
  String? price;

  CryptoResponseModel copyWith({String? symbol, String? price}) =>
      CryptoResponseModel(
        symbol: symbol ?? this.symbol,
        price: price ?? this.price,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
    map['price'] = price;
    return map;
  }
}
