import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../models/coin_model.dart';
import 'price_change_badge.dart';

class CryptoCoinTile extends StatelessWidget {
  final CoinModel coin;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const CryptoCoinTile({
    super.key,
    required this.coin,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Coin avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                coin.symbol.isNotEmpty ? coin.symbol[0] : '?',
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Symbol & Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/USDT',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Price info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(coin.currentPrice),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vol ${Formatters.compactVolume(coin.volume24h)}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 24h Percentage
            PriceChangeBadge(
              percentage: coin.priceChangePercentage24h,
              isCompact: true,
            ),
            if (onFavoriteToggle != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  coin.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: coin.isFavorite ? AppColors.warningGold : AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
