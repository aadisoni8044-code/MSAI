import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/coin_model.dart';
import '../../../shared/widgets/crypto_chart.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/price_change_badge.dart';
import '../../../shared/widgets/primary_button.dart';
import '../home/presentation/home_provider.dart';
import 'coin_details_provider.dart';

class CoinDetailsScreen extends ConsumerWidget {
  final CoinModel coin;
  final Function(String symbol, bool isBuy) onTradeTap;

  const CoinDetailsScreen({
    super.key,
    required this.coin,
    required this.onTradeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinAsync = ref.watch(coinDetailsProvider(coin.symbol));
    final candlesticksAsync = ref.watch(coinCandlesticksProvider(coin.symbol));
    final timeframe = ref.watch(coinDetailsTimeframeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.surfaceLight,
              child: Text(coin.symbol[0], style: const TextStyle(fontSize: 10, color: AppColors.primaryAccent)),
            ),
            const SizedBox(width: 8),
            Text(
              '${coin.symbol}/USDT',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              coin.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: coin.isFavorite ? AppColors.warningGold : AppColors.textSecondary,
            ),
            onPressed: () async {
              await ref.read(marketRepositoryProvider).toggleFavorite(coin.symbol);
              ref.invalidate(coinDetailsProvider(coin.symbol));
            },
          ),
        ],
      ),
      body: coinAsync.when(
        data: (coinData) {
          final currentCoin = coinData ?? coin;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Price Block
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.currency(currentCoin.currentPrice),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  PriceChangeBadge(percentage: currentCoin.priceChangePercentage24h),
                                  const SizedBox(width: 8),
                                  Text(
                                    Formatters.currency(currentCoin.priceChange24h),
                                    style: TextStyle(
                                      color: currentCoin.priceChange24h >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chart
                      candlesticksAsync.when(
                        data: (candles) => CryptoChart(
                          candlesticks: candles,
                          selectedTimeframe: timeframe,
                          onTimeframeChanged: (tf) {
                            ref.read(coinDetailsTimeframeProvider.notifier).state = tf;
                          },
                        ),
                        loading: () => const SizedBox(height: 260, child: LoadingWidget()),
                        error: (_, __) => const CustomErrorWidget(message: 'Failed to load chart data'),
                      ),
                      const SizedBox(height: 24),

                      // 24h Statistics Table
                      const Text(
                        '24h Market Statistics',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow('24h High', Formatters.currency(currentCoin.high24h)),
                            const Divider(height: 16, color: AppColors.divider),
                            _buildStatRow('24h Low', Formatters.currency(currentCoin.low24h)),
                            const Divider(height: 16, color: AppColors.divider),
                            _buildStatRow('24h Volume', Formatters.compactVolume(currentCoin.volume24h)),
                            const Divider(height: 16, color: AppColors.divider),
                            _buildStatRow('Market Cap', Formatters.compactVolume(currentCoin.marketCap)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Buy',
                        color: AppColors.profitGreen,
                        onPressed: () => onTradeTap('${currentCoin.symbol}/USDT', true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Sell',
                        color: AppColors.lossRed,
                        onPressed: () => onTradeTap('${currentCoin.symbol}/USDT', false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => CustomErrorWidget(message: 'Failed to load coin details'),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
