import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/coin_model.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/crypto_coin_tile.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/market_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  final Function(CoinModel) onCoinTap;
  final VoidCallback onSeeAllMarkets;
  final VoidCallback onDepositTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onBuyTap;

  const HomeScreen({
    super.key,
    required this.onCoinTap,
    required this.onSeeAllMarkets,
    required this.onDepositTap,
    required this.onWithdrawTap,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletOverviewProvider);
    final trendingAsync = ref.watch(trendingCoinsProvider);
    final favoritesAsync = ref.watch(favoriteCoinsProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.candlestick_chart_rounded, color: AppColors.primaryAccent, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('CryptoX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletOverviewProvider);
          ref.invalidate(trendingCoinsProvider);
          ref.invalidate(favoriteCoinsProvider);
          ref.invalidate(recentTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Overview Card
              walletAsync.when(
                data: (wallet) => BalanceCard(
                  totalBalance: wallet.totalPortfolioValue,
                  change24h: 3.84,
                  onDeposit: onDepositTap,
                  onWithdraw: onWithdrawTap,
                  onBuy: onBuyTap,
                ),
                loading: () => const SizedBox(height: 140, child: LoadingWidget()),
                error: (err, stack) => CustomErrorWidget(message: 'Failed to load portfolio balance', onRetry: () => ref.refresh(walletOverviewProvider)),
              ),
              const SizedBox(height: 24),

              // Favorites Section
              _buildSectionHeader(
                title: 'Favorite Coins',
                onSeeAll: onSeeAllMarkets,
              ),
              const SizedBox(height: 12),
              favoritesAsync.when(
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No favorite coins added yet.', style: TextStyle(color: AppColors.textTertiary)),
                    );
                  }
                  return SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return MarketCard(
                          coin: favorites[index],
                          onTap: () => onCoinTap(favorites[index]),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(height: 100, child: LoadingWidget()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Trending Coins
              _buildSectionHeader(
                title: 'Trending Markets',
                onSeeAll: onSeeAllMarkets,
              ),
              const SizedBox(height: 8),
              trendingAsync.when(
                data: (coins) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: coins.length,
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      return CryptoCoinTile(
                        coin: coin,
                        onTap: () => onCoinTap(coin),
                        onFavoriteToggle: () async {
                          await ref.read(marketRepositoryProvider).toggleFavorite(coin.symbol);
                          ref.invalidate(trendingCoinsProvider);
                          ref.invalidate(favoriteCoinsProvider);
                        },
                      );
                    },
                  );
                },
                loading: () => const LoadingWidget(),
                error: (err, stack) => CustomErrorWidget(message: 'Failed to load market trends'),
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              _buildSectionHeader(
                title: 'Recent Activity',
              ),
              const SizedBox(height: 8),
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No recent transactions.', style: TextStyle(color: AppColors.textTertiary)),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.take(4).length,
                    itemBuilder: (context, index) {
                      return TransactionTile(transaction: transactions[index]);
                    },
                  );
                },
                loading: () => const LoadingWidget(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryAccent, size: 12),
              ],
            ),
          ),
      ],
    );
  }
}
