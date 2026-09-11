import 'package:flutter_test/flutter_test.dart';
import 'package:cryptox/shared/models/coin_model.dart';
import 'package:cryptox/shared/models/order_model.dart';
import 'package:cryptox/core/utils/formatters.dart';

void main() {
  group('Data Models & Formatters Tests', () {
    test('CoinModel JSON serialization and deserialization', () {
      const coin = CoinModel(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        iconUrl: 'assets/btc.png',
        currentPrice: 67450.25,
        priceChange24h: 2200.0,
        priceChangePercentage24h: 3.45,
        high24h: 68200.0,
        low24h: 65100.0,
        volume24h: 34500000000.0,
        marketCap: 1320000000000.0,
        isFavorite: true,
      );

      final json = coin.toJson();
      final restored = CoinModel.fromJson(json);

      expect(restored.id, coin.id);
      expect(restored.symbol, coin.symbol);
      expect(restored.currentPrice, coin.currentPrice);
      expect(restored.isFavorite, coin.isFavorite);
    });

    test('OrderModel calculations', () {
      final order = OrderModel(
        id: 'ORD-123',
        pair: 'BTC/USDT',
        type: OrderType.limit,
        side: OrderSide.buy,
        price: 50000.0,
        amount: 2.0,
        filledAmount: 1.0,
        status: OrderStatus.open,
        dateTime: DateTime.now(),
      );

      expect(order.total, 100000.0);
      expect(order.fillPercentage, 50.0);
      expect(order.isBuy, true);
    });

    test('Formatters test', () {
      expect(Formatters.percentage(3.456), '+3.46%');
      expect(Formatters.percentage(-1.2), '-1.20%');
      expect(Formatters.compactVolume(1500000), '\$1.50M');
      expect(Formatters.compactVolume(2500000000), '\$2.50B');
    });
  });
}
