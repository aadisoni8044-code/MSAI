import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/candlestick_model.dart';
import '../../../shared/models/coin_model.dart';
import '../../home/presentation/home_provider.dart';

final coinDetailsTimeframeProvider = StateProvider<String>((ref) => '1H');

final coinDetailsProvider = FutureProvider.family<CoinModel?, String>((ref, symbol) async {
  return ref.watch(marketRepositoryProvider).getCoinBySymbol(symbol);
});

final coinCandlesticksProvider = FutureProvider.family<List<CandlestickModel>, String>((ref, symbol) async {
  final timeframe = ref.watch(coinDetailsTimeframeProvider);
  return ref.watch(marketRepositoryProvider).getCandlesticks(symbol, timeframe);
});
