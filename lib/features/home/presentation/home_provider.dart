import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/coin_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../markets/data/mock_market_service.dart';
import '../markets/domain/market_repository.dart';
import '../wallet/data/mock_wallet_service.dart';
import '../wallet/domain/wallet_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MockMarketService();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return MockWalletService();
});

final coinsProvider = FutureProvider<List<CoinModel>>((ref) async {
  return ref.watch(marketRepositoryProvider).getCoins();
});

final walletOverviewProvider = FutureProvider<WalletModel>((ref) async {
  return ref.watch(walletRepositoryProvider).getWalletOverview();
});

final recentTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  return ref.watch(walletRepositoryProvider).getRecentTransactions();
});

final trendingCoinsProvider = FutureProvider<List<CoinModel>>((ref) async {
  final coins = await ref.watch(marketRepositoryProvider).getCoins();
  final list = List<CoinModel>.from(coins);
  list.sort((a, b) => b.priceChangePercentage24h.abs().compareTo(a.priceChangePercentage24h.abs()));
  return list.take(5).toList();
});

final favoriteCoinsProvider = FutureProvider<List<CoinModel>>((ref) async {
  final coins = await ref.watch(marketRepositoryProvider).getCoins();
  return coins.where((c) => c.isFavorite).toList();
});
