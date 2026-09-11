import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.arrow_downward_rounded;
        iconColor = AppColors.profitGreen;
        break;
      case TransactionType.withdraw:
        icon = Icons.arrow_upward_rounded;
        iconColor = AppColors.lossRed;
        break;
      case TransactionType.buy:
        icon = Icons.add_shopping_cart_rounded;
        iconColor = AppColors.primaryAccent;
        break;
      case TransactionType.sell:
        icon = Icons.sell_outlined;
        iconColor = AppColors.warningGold;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz_rounded;
        iconColor = AppColors.infoBlue;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withAlpha(25),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.dateTime(transaction.timestamp),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount} ${transaction.symbol}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.currency(transaction.valueUsd),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
