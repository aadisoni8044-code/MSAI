import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PriceChangeBadge extends StatelessWidget {
  final double percentage;
  final bool isCompact;

  const PriceChangeBadge({
    super.key,
    required this.percentage,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percentage >= 0;
    final bgColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;
    final prefix = isPositive ? '+' : '';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$prefix${percentage.toStringAsFixed(2)}%',
        style: TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 12 : 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
