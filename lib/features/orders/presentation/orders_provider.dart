import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/order_model.dart';
import '../data/mock_order_service.dart';
import '../domain/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderService();
});

final openOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getOpenOrders();
});

final orderHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getOrderHistory();
});

final tradeHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getTradeHistory();
});
