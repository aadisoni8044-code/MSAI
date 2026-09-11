import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PercentageShortcuts extends StatelessWidget {
  final ValueChanged<int> onSelected;

  const PercentageShortcuts({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final percentages = [25, 50, 75, 100];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: percentages.map((percent) {
        return InkWell(
          onTap: () => onSelected(percent),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
