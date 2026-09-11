import 'dart:async';
import 'dart:math';
import '../../shared/models/order_book_model.dart';

class WebSocketService {
  final _orderBookController = StreamController<OrderBookModel>.broadcast();
  final _priceTickerController = StreamController<Map<String, double>>.broadcast();
  Timer? _timer;
  final _random = Random();

  Stream<OrderBookModel> get orderBookStream => _orderBookController.stream;
  Stream<Map<String, double>> get priceTickerStream => _priceTickerController.stream;

  void subscribeToPair(String symbol, double basePrice) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_orderBookController.isClosed) return;

      final variance = (basePrice * 0.002);
      final currentPrice = basePrice + (_random.nextDouble() * variance * 2 - variance);

      // Generate order book asks and bids
      final asks = <OrderBookEntry>[];
      final bids = <OrderBookEntry>[];

      double cumulativeAskVol = 0;
      for (int i = 1; i <= 8; i++) {
        final price = currentPrice + (i * basePrice * 0.0008);
        final amount = _random.nextDouble() * 2.5 + 0.1;
        cumulativeAskVol += amount;
        asks.add(OrderBookEntry(
          price: price,
          amount: amount,
          total: price * amount,
          depthPercentage: min(1.0, cumulativeAskVol / 20.0),
        ));
      }

      double cumulativeBidVol = 0;
      for (int i = 1; i <= 8; i++) {
        final price = currentPrice - (i * basePrice * 0.0008);
        final amount = _random.nextDouble() * 2.5 + 0.1;
        cumulativeBidVol += amount;
        bids.add(OrderBookEntry(
          price: price,
          amount: amount,
          total: price * amount,
          depthPercentage: min(1.0, cumulativeBidVol / 20.0),
        ));
      }

      _orderBookController.add(OrderBookModel(
        symbol: symbol,
        asks: asks.reversed.toList(),
        bids: bids,
        currentPrice: currentPrice,
        priceChange24h: 2.45,
      ));

      _priceTickerController.add({
        symbol: currentPrice,
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _orderBookController.close();
    _priceTickerController.close();
  }
}
