class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String iconUrl;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double marketCap;
  final bool isFavorite;
  final List<double> sparklineData;

  const CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.marketCap,
    this.isFavorite = false,
    this.sparklineData = const [],
  });

  CoinModel copyWith({
    String? id,
    String? symbol,
    String? name,
    String? iconUrl,
    double? currentPrice,
    double? priceChange24h,
    double? priceChangePercentage24h,
    double? high24h,
    double? low24h,
    double? volume24h,
    double? marketCap,
    bool? isFavorite,
    List<double>? sparklineData,
  }) {
    return CoinModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      priceChangePercentage24h: priceChangePercentage24h ?? this.priceChangePercentage24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      marketCap: marketCap ?? this.marketCap,
      isFavorite: isFavorite ?? this.isFavorite,
      sparklineData: sparklineData ?? this.sparklineData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'iconUrl': iconUrl,
      'currentPrice': currentPrice,
      'priceChange24h': priceChange24h,
      'priceChangePercentage24h': priceChangePercentage24h,
      'high24h': high24h,
      'low24h': low24h,
      'volume24h': volume24h,
      'marketCap': marketCap,
      'isFavorite': isFavorite,
      'sparklineData': sparklineData,
    };
  }

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      priceChangePercentage24h: (json['priceChangePercentage24h'] as num).toDouble(),
      high24h: (json['high24h'] as num).toDouble(),
      low24h: (json['low24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      marketCap: (json['marketCap'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      sparklineData: (json['sparklineData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}
