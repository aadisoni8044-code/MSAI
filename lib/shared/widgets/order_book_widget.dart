import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../models/order_book_model.dart';

class OrderBookWidget extends StatelessWidget {
  final OrderBookModel orderBook;
  final Function(double price)? onPriceSelect;

  const OrderBookWidget({
    super.key,
    required this.orderBook,
    this.onPriceSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price (USDT)', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              Text('Amount', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              Text('Total', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
        // Asks (Sells - Red)
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderBook.asks.take(6).length,
          itemBuilder: (context, index) {
            final entry = orderBook.asks[index];
            return _buildRow(context, entry, AppColors.lossRed, isAsk: true);
          },
        ),
        // Spread / Current Price
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Text(
                Formatters.currency(orderBook.currentPrice),
                style: const TextStyle(
                  color: AppColors.profitGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${orderBook.priceChange24h >= 0 ? '+' : ''}${orderBook.priceChange24h}%',
                style: TextStyle(
                  color: orderBook.priceChange24h >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Bids (Buys - Green)
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderBook.bids.take(6).length,
          itemBuilder: (context, index) {
            final entry = orderBook.bids[index];
            return _buildRow(context, entry, AppColors.profitGreen, isAsk: false);
          },
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, OrderBookEntry entry, Color color, {required bool isAsk}) {
    return InkWell(
      onTap: () {
        if (onPriceSelect != null) {
          onPriceSelect!(entry.price);
        }
      },
      child: Stack(
        children: [
          // Depth bar background
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: entry.depthPercentage.clamp(0.05, 1.0),
              child: Container(
                height: 24,
                color: color.withAlpha(25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.number(entry.price, decimals: 2),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  Formatters.number(entry.amount, decimals: 4),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  Formatters.compactVolume(entry.total),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
