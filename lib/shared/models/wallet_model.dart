class WalletAsset {
  final String symbol;
  final String name;
  final String iconUrl;
  final double quantity;
  final double lockedQuantity;
  final double currentPrice;
  final double priceChange24h;

  const WalletAsset({
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.quantity,
    required this.lockedQuantity,
    required this.currentPrice,
    required this.priceChange24h,
  });

  double get totalQuantity => quantity + lockedQuantity;
  double get totalValue => totalQuantity * currentPrice;
  double get availableValue => quantity * currentPrice;

  WalletAsset copyWith({
    String? symbol,
    String? name,
    String? iconUrl,
    double? quantity,
    double? lockedQuantity,
    double? currentPrice,
    double? priceChange24h,
  }) {
    return WalletAsset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      quantity: quantity ?? this.quantity,
      lockedQuantity: lockedQuantity ?? this.lockedQuantity,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
    );
  }
}

class WalletModel {
  final double fiatBalance;
  final List<WalletAsset> cryptoAssets;

  const WalletModel({
    required this.fiatBalance,
    required this.cryptoAssets,
  });

  double get cryptoTotalValue => cryptoAssets.fold(0, (sum, asset) => sum + asset.totalValue);
  double get totalPortfolioValue => fiatBalance + cryptoTotalValue;
}
