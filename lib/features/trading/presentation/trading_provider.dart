import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/order_model.dart';
import '../data/mock_trading_service.dart';
import '../domain/trading_repository.dart';

final tradingRepositoryProvider = Provider<TradingRepository>((ref) {
  return MockTradingService();
});

class TradingFormState {
  final OrderType orderType;
  final OrderSide orderSide;
  final double price;
  final double stopPrice;
  final double amount;
  final double total;
  final bool isLoading;
  final String? errorMessage;

  const TradingFormState({
    this.orderType = OrderType.limit,
    this.orderSide = OrderSide.buy,
    this.price = 0.0,
    this.stopPrice = 0.0,
    this.amount = 0.0,
    this.total = 0.0,
    this.isLoading = false,
    this.errorMessage,
  });

  TradingFormState copyWith({
    OrderType? orderType,
    OrderSide? orderSide,
    double? price,
    double? stopPrice,
    double? amount,
    double? total,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TradingFormState(
      orderType: orderType ?? this.orderType,
      orderSide: orderSide ?? this.orderSide,
      price: price ?? this.price,
      stopPrice: stopPrice ?? this.stopPrice,
      amount: amount ?? this.amount,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TradingNotifier extends StateNotifier<TradingFormState> {
  final TradingRepository _repository;

  TradingNotifier(this._repository) : super(const TradingFormState());

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setOrderSide(OrderSide side) {
    state = state.copyWith(orderSide: side);
  }

  void updatePrice(double price) {
    final total = price * state.amount;
    state = state.copyWith(price: price, total: total);
  }

  void updateStopPrice(double stopPrice) {
    state = state.copyWith(stopPrice: stopPrice);
  }

  void updateAmount(double amount) {
    final total = state.price * amount;
    state = state.copyWith(amount: amount, total: total);
  }

  void setPercentageOfBalance(int percentage, double availableBalance) {
    final targetValue = availableBalance * (percentage / 100.0);
    if (state.price > 0) {
      final amount = targetValue / state.price;
      state = state.copyWith(amount: amount, total: targetValue);
    } else {
      state = state.copyWith(total: targetValue);
    }
  }

  Future<OrderModel?> submitOrder({
    required String pair,
    required double availableBalance,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.validateOrder(
        price: state.price,
        amount: state.amount,
        availableBalance: availableBalance,
      );

      final order = await _repository.placeOrder(
        pair: pair,
        type: state.orderType,
        side: state.orderSide,
        price: state.price,
        amount: state.amount,
        stopPrice: state.orderType == OrderType.stopLimit ? state.stopPrice : null,
      );

      state = state.copyWith(isLoading: false);
      return order;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }
}

final tradingNotifierProvider = StateNotifierProvider.autoDispose<TradingNotifier, TradingFormState>((ref) {
  return TradingNotifier(ref.watch(tradingRepositoryProvider));
});
