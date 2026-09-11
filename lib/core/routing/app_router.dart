import 'package:flutter/material.dart';
import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/coin_details/presentation/coin_details_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/trading/presentation/trading_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../shared/models/coin_model.dart';

enum AuthScreenRoute { splash, login, register, forgotPassword, emailVerification }

class AppRouter {
  static Widget buildAuthFlow({
    required AuthScreenRoute route,
    required Function(AuthScreenRoute) onNavigate,
    required VoidCallback onAuthenticated,
  }) {
    switch (route) {
      case AuthScreenRoute.splash:
        return SplashScreen(onFinish: () => onNavigate(AuthScreenRoute.login));
      case AuthScreenRoute.login:
        return LoginScreen(
          onRegisterTap: () => onNavigate(AuthScreenRoute.register),
          onForgotPasswordTap: () => onNavigate(AuthScreenRoute.forgotPassword),
        );
      case AuthScreenRoute.register:
        return RegisterScreen(
          onLoginTap: () => onNavigate(AuthScreenRoute.login),
        );
      case AuthScreenRoute.forgotPassword:
        return ForgotPasswordScreen(
          onBackTap: () => onNavigate(AuthScreenRoute.login),
        );
      case AuthScreenRoute.emailVerification:
        return EmailVerificationScreen(
          onContinue: onAuthenticated,
        );
    }
  }

  static Widget buildScreenForTab({
    required int index,
    required Function(CoinModel) onCoinTap,
    required VoidCallback onSeeAllMarkets,
    required VoidCallback onDepositTap,
    required VoidCallback onWithdrawTap,
    required VoidCallback onBuyTap,
    required String? activeTradingPair,
  }) {
    switch (index) {
      case 0:
        return HomeScreen(
          onCoinTap: onCoinTap,
          onSeeAllMarkets: onSeeAllMarkets,
          onDepositTap: onDepositTap,
          onWithdrawTap: onWithdrawTap,
          onBuyTap: onBuyTap,
        );
      case 1:
        return MarketsScreen(onCoinTap: onCoinTap);
      case 2:
        return TradingScreen(initialPair: activeTradingPair);
      case 3:
        return const OrdersScreen();
      case 4:
        return const WalletScreen();
      default:
        return HomeScreen(
          onCoinTap: onCoinTap,
          onSeeAllMarkets: onSeeAllMarkets,
          onDepositTap: onDepositTap,
          onWithdrawTap: onWithdrawTap,
          onBuyTap: onBuyTap,
        );
    }
  }
}
