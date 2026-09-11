import '../../../shared/models/order_model.dart';
import '../domain/order_repository.dart';

class MockOrderService implements OrderRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-8F92A1',
      pair: 'BTC/USDT',
      type: OrderType.limit,
      side: OrderSide.buy,
      price: 66500.0,
      amount: 0.15,
      filledAmount: 0.0,
      status: OrderStatus.open,
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    OrderModel(
      id: 'ORD-3C41B8',
      pair: 'ETH/USDT',
      type: OrderType.limit,
      side: OrderSide.sell,
      price: 3550.0,
      amount: 1.5,
      filledAmount: 0.0,
      status: OrderStatus.open,
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    OrderModel(
      id: 'ORD-12A9E4',
      pair: 'SOL/USDT',
      type: OrderType.market,
      side: OrderSide.buy,
      price: 175.20,
      amount: 10.0,
      filledAmount: 10.0,
      status: OrderStatus.filled,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ORD-98D7F6',
      pair: 'BTC/USDT',
      type: OrderType.limit,
      side: OrderSide.sell,
      price: 68000.0,
      amount: 0.05,
      filledAmount: 0.05,
      status: OrderStatus.filled,
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<OrderModel>> getOpenOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.status == OrderStatus.open).toList();
  }

  @override
  Future<List<OrderModel>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.status != OrderStatus.open).toList();
  }

  @override
  Future<List<OrderModel>> getTradeHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.status == OrderStatus.filled).toList();
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.canceled);
    }
  }

  @override
  Future<void> addOrder(OrderModel order) async {
    _orders.insert(0, order);
  }
}
