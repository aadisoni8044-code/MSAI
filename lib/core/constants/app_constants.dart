class AppConstants {
  static const String appName = 'CryptoX';
  static const String appVersion = '1.0.0';

  // Local Storage Keys
  static const String storageAuthToken = 'cryptox_auth_token';
  static const String storageUserKey = 'cryptox_user_data';
  static const String storageFavoritesKey = 'cryptox_favorites';

  // Default Pairs
  static const List<String> popularSymbols = [
    'BTC',
    'ETH',
    'BNB',
    'SOL',
    'XRP',
    'DOGE',
    'ADA',
    'TRX'
  ];

  // Chart Timeframes
  static const List<String> timeframes = [
    '1m',
    '5m',
    '15m',
    '1H',
    '4H',
    '1D',
    '1W'
  ];
}
