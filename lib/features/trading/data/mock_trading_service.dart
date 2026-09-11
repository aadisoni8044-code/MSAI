import 'package:uuid/uuid.dart';
import '../../../shared/models/order_model.dart';
import '../domain/trading_repository.dart';

class MockTradingService implements TradingRepository {
  final _uuid = const Uuid();

  @override
  Future<void> validateOrder({
    required double price,
    required double amount,
    required double availableBalance,
  }) async {
    if (price <= 0) {
      throw Exception('Price must be greater than zero.');
    }
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }
    final total = price * amount;
    if (total > availableBalance) {
      throw Exception('Insufficient funds. Required: \$${total.toStringAsFixed(2)}, Available: \$${availableBalance.toStringAsFixed(2)}');
    }
  }

  @override
  Future<OrderModel> placeOrder({
    required String pair,
    required OrderType type,
    required OrderSide side,
    required double price,
    required double amount,
    double? stopPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final isMarket = type == OrderType.market;
    final order = OrderModel(
      id: 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}',
      pair: pair,
      type: type,
      side: side,
      price: price,
      stopPrice: stopPrice,
      amount: amount,
      filledAmount: isMarket ? amount : 0.0,
      status: isMarket ? OrderStatus.filled : OrderStatus.open,
      dateTime: DateTime.now(),
    );

    return order;
  }
}
