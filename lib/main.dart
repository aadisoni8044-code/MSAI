import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/coin_details/presentation/coin_details_screen.dart';
import 'shared/models/coin_model.dart';
import 'shared/widgets/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CryptoXApp()));
}

class CryptoXApp extends ConsumerStatefulWidget {
  const CryptoXApp({super.key});

  @override
  ConsumerState<CryptoXApp> createState() => _CryptoXAppState();
}

class _CryptoXAppState extends ConsumerState<CryptoXApp> {
  int _currentTabIndex = 0;
  AuthScreenRoute _authRoute = AuthScreenRoute.splash;
  CoinModel? _selectedCoin;
  String? _activeTradingPair;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CryptoX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: userAsync.when(
        data: (user) {
          if (user == null) {
            return AppRouter.buildAuthFlow(
              route: _authRoute,
              onNavigate: (route) {
                setState(() {
                  _authRoute = route;
                });
              },
              onAuthenticated: () {},
            );
          }

          if (_selectedCoin != null) {
            return CoinDetailsScreen(
              coin: _selectedCoin!,
              onTradeTap: (pair, isBuy) {
                setState(() {
                  _activeTradingPair = pair;
                  _selectedCoin = null;
                  _currentTabIndex = 2; // Jump to Trade tab
                });
              },
            );
          }

          return MainShell(
            currentIndex: _currentTabIndex,
            onTabSelected: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            body: AppRouter.buildScreenForTab(
              index: _currentTabIndex,
              activeTradingPair: _activeTradingPair,
              onCoinTap: (coin) {
                setState(() {
                  _selectedCoin = coin;
                });
              },
              onSeeAllMarkets: () {
                setState(() {
                  _currentTabIndex = 1; // Jump to Markets tab
                });
              },
              onDepositTap: () {
                setState(() {
                  _currentTabIndex = 4; // Jump to Wallet tab
                });
              },
              onWithdrawTap: () {
                setState(() {
                  _currentTabIndex = 4; // Jump to Wallet tab
                });
              },
              onBuyTap: () {
                setState(() {
                  _currentTabIndex = 2; // Jump to Trade tab
                });
              },
            ),
          );
        },
        loading: () => Scaffold(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Scaffold(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          body: const Center(child: Text('Initialization Error')),
        ),
      ),
    );
  }
}
