import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MainShell extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget body;

  const MainShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.body,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarThemeItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarThemeItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Markets',
          ),
          BottomNavigationBarThemeItem(
            icon: Icon(Icons.swap_horizontal_circle_outlined),
            activeIcon: Icon(Icons.swap_horizontal_circle_rounded),
            label: 'Trade',
          ),
          BottomNavigationBarThemeItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarThemeItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarThemeItem extends BottomNavigationBarItem {
  const BottomNavigationBarThemeItem({
    required super.icon,
    super.activeIcon,
    required super.label,
  });
}
