import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/coin_model.dart';
import '../../../shared/widgets/crypto_coin_tile.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../home/presentation/home_provider.dart';
import 'markets_provider.dart';

class MarketsScreen extends ConsumerWidget {
  final Function(CoinModel) onCoinTap;

  const MarketsScreen({super.key, required this.onCoinTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(marketFilterProvider);
    final coinsAsync = ref.watch(filteredCoinsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Markets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) {
                ref.read(marketFilterProvider.notifier).setSearchQuery(val);
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search coins (e.g. BTC, ETH)',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: filterState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          ref.read(marketFilterProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryChip(ref, MarketCategory.all, 'All Coins', filterState.category),
                _buildCategoryChip(ref, MarketCategory.favorites, 'Favorites', filterState.category),
                _buildCategoryChip(ref, MarketCategory.usdt, 'USDT Pairs', filterState.category),
                _buildCategoryChip(ref, MarketCategory.topGainers, 'Top Gainers', filterState.category),
                _buildCategoryChip(ref, MarketCategory.topLosers, 'Top Losers', filterState.category),
              ],
            ),
          ),

          // Sorting Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ref.read(marketFilterProvider.notifier).setSort(MarketSortField.name),
                    child: Row(
                      children: [
                        const Text('Name / Vol', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                        if (filterState.sortField == MarketSortField.name)
                          Icon(filterState.isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: AppColors.primaryAccent),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => ref.read(marketFilterProvider.notifier).setSort(MarketSortField.price),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Last Price', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                          if (filterState.sortField == MarketSortField.price)
                            Icon(filterState.isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: AppColors.primaryAccent),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () => ref.read(marketFilterProvider.notifier).setSort(MarketSortField.change24h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('24h Change', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      if (filterState.sortField == MarketSortField.change24h)
                        Icon(filterState.isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: AppColors.primaryAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Coins List
          Expanded(
            child: coinsAsync.when(
              data: (coins) {
                if (coins.isEmpty) {
                  return const Center(
                    child: Text('No cryptocurrencies found.', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredCoinsProvider);
                  },
                  child: ListView.separated(
                    itemCount: coins.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      return CryptoCoinTile(
                        coin: coin,
                        onTap: () => onCoinTap(coin),
                        onFavoriteToggle: () async {
                          await ref.read(marketRepositoryProvider).toggleFavorite(coin.symbol);
                          ref.invalidate(filteredCoinsProvider);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, stack) => CustomErrorWidget(
                message: 'Failed to load market data',
                onRetry: () => ref.refresh(filteredCoinsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(WidgetRef ref, MarketCategory category, String label, MarketCategory activeCategory) {
    final isSelected = category == activeCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(marketFilterProvider.notifier).setCategory(category);
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceLight,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide.none,
      ),
    );
  }
}
