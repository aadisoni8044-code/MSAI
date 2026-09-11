# CryptoX - Modern Cryptocurrency Trading Mobile Application

CryptoX is a modern, responsive mobile cryptocurrency exchange and trading simulator application built with **Flutter**, **Dart**, **Material 3**, and **Riverpod**.

Designed with a premium dark crypto-exchange interface inspired by major industry exchanges, CryptoX offers a full suite of trading, market analysis, portfolio management, and order tracking features with completely original branding and UI assets.

---

## Key Features

- **Home Dashboard**: Total portfolio balance, 24h gain/loss tracker, quick Deposit/Withdraw/Buy actions, favorite coins carousel, trending coins table, and recent activity log.
- **Markets Dashboard**: Real-time coin list with search bar, filter chips (Favorites, All Coins, USDT pairs, Top Gainers, Top Losers), multi-column sorting (Name, Price, 24h Change, Volume), and mini price charts.
- **Coin Details & Interactive Charts**: Live price tracking, 24h high/low/volume/market cap stats, timeframe selector (`1m`, `5m`, `15m`, `1H`, `4H`, `1D`, `1W`), interactive charts via `fl_chart`, and direct Buy/Sell quick actions.
- **Spot Trading Simulator**: Pair selector modal (`BTC/USDT`, `ETH/USDT`, `SOL/USDT`, etc.), Buy/Sell toggle, order type selector (Limit, Market, Stop-Limit), percentage shortcut buttons (`25%`, `50%`, `75%`, `100%`), input validation, and order execution confirmation modal.
- **Real-Time Order Book**: Visual depth bars, live bid/ask order book streaming simulated via WebSocket streams.
- **Orders Management**: Tabbed view for Open Orders, Order History, and Trade History with open order cancellation.
- **Wallet & Asset Management**: Total portfolio breakdown, fiat/crypto holdings list, and interactive modals for mock Deposit, Withdrawal, and Internal Transfer actions.
- **Authentication Flow**: Splash screen, Login, Registration, Forgot Password, and Email Verification screens with persistent session storage.

---

## Project Folder Structure

Follows **Clean Architecture** with a feature-first organization:

```text
lib/
├── core/
│   ├── constants/        # AppColors, AppConstants
│   ├── network/          # WebSocketService
│   ├── routing/          # AppRouter
│   ├── theme/            # AppTheme (Material 3 dark theme)
│   └── utils/            # Formatters (currency, percentage, volume, dates)
├── features/
│   ├── auth/             # AuthService, MockAuthService, AuthState, Auth Screens
│   ├── coin_details/     # CoinDetailsScreen, CoinDetailsProvider
│   ├── home/             # HomeScreen, HomeProvider
│   ├── markets/          # MarketRepository, MockMarketService, MarketsScreen, MarketsProvider
│   ├── orders/           # OrderRepository, MockOrderService, OrdersScreen, OrdersProvider
│   ├── trading/          # TradingRepository, MockTradingService, TradingScreen, TradingProvider
│   └── wallet/           # WalletRepository, MockWalletService, WalletScreen
├── shared/
│   ├── models/           # CoinModel, CandlestickModel, OrderModel, OrderBookModel, WalletModel, User
│   └── widgets/          # PrimaryButton, SecondaryButton, CryptoCoinTile, CryptoChart, OrderBookWidget, etc.
└── main.dart
```

---

## Setup & Running Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11+ or compatible)
- Dart SDK (v3.0+)
- Android Studio / Xcode / VS Code for mobile emulation

### Steps to Run

1. **Clone Repository & Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Application**:
   - For Mobile Emulator or Web:
     ```bash
     flutter run
     ```
   - For specific target device:
     ```bash
     flutter run -d chrome
     # OR
     flutter run -d android
     ```

3. **Run Unit Tests**:
   ```bash
   flutter test
   ```

4. **Run Static Analysis**:
   ```bash
   flutter analyze lib/
   ```

---

## Firebase Authentication Setup Steps

To connect real **Firebase Authentication** instead of the included `MockAuthService`:

1. Create a Firebase Project at [firebase.google.com](https://console.firebase.google.com/).
2. Add `firebase_core` and `firebase_auth` to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^3.0.0
     firebase_auth: ^5.0.0
   ```
3. Run `flutterfire configure` using the Firebase CLI to generate `firebase_options.dart`.
4. Update `lib/main.dart` initialization:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const ProviderScope(child: CryptoXApp()));
   }
   ```
5. Replace `MockAuthService` in `lib/features/auth/presentation/auth_provider.dart` with `FirebaseAuthService` implementing `AuthRepository`.

---

## How to Replace Mock Market Data with a Real Exchange API

1. Implement `MarketRepository` in `lib/features/markets/data/binance_market_service.dart` using **Dio**:
   ```dart
   class BinanceMarketService implements MarketRepository {
     final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.binance.com'));

     @override
     Future<List<CoinModel>> getCoins() async {
       final response = await _dio.get('/api/v3/ticker/24hr');
       // Map response JSON to List<CoinModel>
     }
   }
   ```
2. Update Riverpod's `marketRepositoryProvider` in `lib/features/home/presentation/home_provider.dart`:
   ```dart
   final marketRepositoryProvider = Provider<MarketRepository>((ref) {
     return BinanceMarketService(); // Replaces MockMarketService
   });
   ```

---

## How to Replace Mock Trading Engine with Production Backend

> **Important**: CryptoX operates as a trading simulator by default. To connect a live exchange trading API or production backend:

1. Implement `TradingRepository` and `OrderRepository` to make REST endpoints / WebSockets to your matching engine API (e.g., `/api/v1/order/place`, `/api/v1/order/cancel`).
2. Provide secure API key management via environment variables or `flutter_secure_storage`:
   ```dart
   final apiKey = await secureStorage.read(key: 'API_KEY');
   final apiSecret = await secureStorage.read(key: 'API_SECRET');
   ```
3. Update `tradingRepositoryProvider` in `lib/features/trading/presentation/trading_provider.dart` to point to the production service.

---

## License & Safety Notice

This application is intended strictly as a **demo / trading simulator**. Do not execute real financial transactions or connect to live real-money exchange accounts unless proper regulatory compliance and custody solutions are integrated.
