class OrderBookEntry {
  final double price;
  final double amount;
  final double total;
  final double depthPercentage;

  const OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
    required this.depthPercentage,
  });
}

class OrderBookModel {
  final String symbol;
  final List<OrderBookEntry> asks; // Sell orders (red)
  final List<OrderBookEntry> bids; // Buy orders (green)
  final double currentPrice;
  final double priceChange24h;

  const OrderBookModel({
    required this.symbol,
    required this.asks,
    required this.bids,
    required this.currentPrice,
    required this.priceChange24h,
  });
}
