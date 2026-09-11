import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/web_socket_service.dart';
import '../../../shared/models/order_book_model.dart';
import '../../home/presentation/home_provider.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final selectedTradingPairProvider = StateProvider<String>((ref) => 'BTC/USDT');

final orderBookProvider = StreamProvider.autoDispose<OrderBookModel>((ref) {
  final pair = ref.watch(selectedTradingPairProvider);
  final wsService = ref.watch(webSocketServiceProvider);
  final marketRepo = ref.watch(marketRepositoryProvider);

  // Subscribe using coin price
  marketRepo.getCoinBySymbol(pair).then((coin) {
    if (coin != null) {
      wsService.subscribeToPair(pair, coin.currentPrice);
    }
  });

  return wsService.orderBookStream;
});
