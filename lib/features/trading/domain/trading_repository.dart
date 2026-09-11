import '../../../shared/models/order_model.dart';

abstract class TradingRepository {
  Future<OrderModel> placeOrder({
    required String pair,
    required OrderType type,
    required OrderSide side,
    required double price,
    required double amount,
    double? stopPrice,
  });

  Future<void> validateOrder({
    required double price,
    required double amount,
    required double availableBalance,
  });
}
