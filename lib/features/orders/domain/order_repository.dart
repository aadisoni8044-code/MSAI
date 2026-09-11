import '../../../shared/models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOpenOrders();
  Future<List<OrderModel>> getOrderHistory();
  Future<List<OrderModel>> getTradeHistory();
  Future<void> cancelOrder(String orderId);
  Future<void> addOrder(OrderModel order);
}
