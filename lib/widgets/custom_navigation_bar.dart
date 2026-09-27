import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.dividerColor, width: 0.8),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primaryBlue.withAlpha(51),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primaryBlue),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_large_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.donut_large_rounded, color: AppColors.primaryBlue),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.phone_rounded, color: AppColors.primaryBlue),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primaryBlue),
            label: 'Communities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
