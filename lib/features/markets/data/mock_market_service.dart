import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/coin_model.dart';
import '../../../shared/models/candlestick_model.dart';
import '../domain/market_repository.dart';

class MockMarketService implements MarketRepository {
  List<CoinModel> _coins = [];
  final Set<String> _favorites = {'BTC', 'ETH', 'SOL'};

  MockMarketService() {
    _initCoins();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(AppConstants.storageFavoritesKey);
      if (saved != null) {
        _favorites.clear();
        _favorites.addAll(saved);
        _updateFavoriteFlags();
      }
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.storageFavoritesKey, _favorites.toList());
    } catch (_) {}
  }

  void _updateFavoriteFlags() {
    _coins = _coins.map((coin) {
      return coin.copyWith(isFavorite: _favorites.contains(coin.symbol));
    }).toList();
  }

  void _initCoins() {
    final rawCoins = [
      {
        'id': 'bitcoin',
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'iconUrl': 'assets/icons/btc.png',
        'price': 67450.25,
        'change24h': 3.45,
        'high24h': 68200.0,
        'low24h': 65100.0,
        'volume24h': 34500000000.0,
        'marketCap': 1320000000000.0,
        'sparkline': [65000.0, 65400.0, 66100.0, 65800.0, 66900.0, 67100.0, 67450.25],
      },
      {
        'id': 'ethereum',
        'symbol': 'ETH',
        'name': 'Ethereum',
        'iconUrl': 'assets/icons/eth.png',
        'price': 3480.10,
        'change24h': -1.25,
        'high24h': 3560.0,
        'low24h': 3410.0,
        'volume24h': 18200000000.0,
        'marketCap': 418000000000.0,
        'sparkline': [3550.0, 3520.0, 3490.0, 3510.0, 3450.0, 3470.0, 3480.10],
      },
      {
        'id': 'binancecoin',
        'symbol': 'BNB',
        'name': 'BNB',
        'iconUrl': 'assets/icons/bnb.png',
        'price': 585.60,
        'change24h': 2.15,
        'high24h': 592.0,
        'low24h': 570.0,
        'volume24h': 1200000000.0,
        'marketCap': 87000000000.0,
        'sparkline': [570.0, 575.0, 580.0, 578.0, 582.0, 584.0, 585.60],
      },
      {
        'id': 'solana',
        'symbol': 'SOL',
        'name': 'Solana',
        'iconUrl': 'assets/icons/sol.png',
        'price': 178.40,
        'change24h': 8.92,
        'high24h': 182.0,
        'low24h': 162.5,
        'volume24h': 5400000000.0,
        'marketCap': 82000000000.0,
        'sparkline': [162.5, 165.0, 170.0, 168.0, 174.0, 176.0, 178.40],
      },
      {
        'id': 'ripple',
        'symbol': 'XRP',
        'name': 'XRP',
        'iconUrl': 'assets/icons/xrp.png',
        'price': 0.584,
        'change24h': -3.12,
        'high24h': 0.612,
        'low24h': 0.570,
        'volume24h': 2100000000.0,
        'marketCap': 32000000000.0,
        'sparkline': [0.605, 0.598, 0.590, 0.585, 0.580, 0.582, 0.584],
      },
      {
        'id': 'dogecoin',
        'symbol': 'DOGE',
        'name': 'Dogecoin',
        'iconUrl': 'assets/icons/doge.png',
        'price': 0.142,
        'change24h': 12.45,
        'high24h': 0.150,
        'low24h': 0.125,
        'volume24h': 3100000000.0,
        'marketCap': 20500000000.0,
        'sparkline': [0.126, 0.128, 0.132, 0.135, 0.138, 0.140, 0.142],
      },
      {
        'id': 'cardano',
        'symbol': 'ADA',
        'name': 'Cardano',
        'iconUrl': 'assets/icons/ada.png',
        'price': 0.465,
        'change24h': 0.85,
        'high24h': 0.480,
        'low24h': 0.455,
        'volume24h': 780000000.0,
        'marketCap': 16500000000.0,
        'sparkline': [0.458, 0.460, 0.462, 0.461, 0.463, 0.464, 0.465],
      },
      {
        'id': 'tron',
        'symbol': 'TRX',
        'name': 'TRON',
        'iconUrl': 'assets/icons/trx.png',
        'price': 0.128,
        'change24h': -0.45,
        'high24h': 0.131,
        'low24h': 0.126,
        'volume24h': 450000000.0,
        'marketCap': 11200000000.0,
        'sparkline': [0.129, 0.128, 0.127, 0.128, 0.129, 0.128, 0.128],
      },
    ];

    _coins = rawCoins.map((item) {
      final symbol = item['symbol'] as String;
      final price = (item['price'] as num).toDouble();
      final change = (item['change24h'] as num).toDouble();
      return CoinModel(
        id: item['id'] as String,
        symbol: symbol,
        name: item['name'] as String,
        iconUrl: item['iconUrl'] as String,
        currentPrice: price,
        priceChange24h: price * (change / 100),
        priceChangePercentage24h: change,
        high24h: (item['high24h'] as num).toDouble(),
        low24h: (item['low24h'] as num).toDouble(),
        volume24h: (item['volume24h'] as num).toDouble(),
        marketCap: (item['marketCap'] as num).toDouble(),
        isFavorite: _favorites.contains(symbol),
        sparklineData: (item['sparkline'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      );
    }).toList();
  }

  @override
  Future<List<CoinModel>> getCoins() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _coins;
  }

  @override
  Future<CoinModel?> getCoinBySymbol(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final normalized = symbol.replaceAll('USDT', '').toUpperCase();
    try {
      return _coins.firstWhere((c) => c.symbol.toUpperCase() == normalized);
    } catch (_) {
      return _coins.isNotEmpty ? _coins.first : null;
    }
  }

  @override
  Future<List<CandlestickModel>> getCandlesticks(String symbol, String timeframe) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final coin = await getCoinBySymbol(symbol);
    final basePrice = coin?.currentPrice ?? 100.0;

    final List<CandlestickModel> list = [];
    final random = Random(symbol.hashCode + timeframe.hashCode);
    var current = basePrice * 0.9;
    final now = DateTime.now();

    final count = 30;
    for (int i = count; i >= 0; i--) {
      final change = (random.nextDouble() - 0.48) * (basePrice * 0.03);
      final open = current;
      final close = open + change;
      final high = max(open, close) + random.nextDouble() * (basePrice * 0.015);
      final low = min(open, close) - random.nextDouble() * (basePrice * 0.015);
      final volume = random.nextDouble() * 500000 + 100000;

      list.add(CandlestickModel(
        timestamp: now.subtract(Duration(hours: i * 2)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));
      current = close;
    }
    return list;
  }

  @override
  Future<List<CoinModel>> getTopGainers() async {
    final list = List<CoinModel>.from(_coins);
    list.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    return list;
  }

  @override
  Future<List<CoinModel>> getTopLosers() async {
    final list = List<CoinModel>.from(_coins);
    list.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    return list;
  }

  @override
  Future<List<CoinModel>> searchCoins(String query) async {
    if (query.trim().isEmpty) return _coins;
    final q = query.toLowerCase();
    return _coins.where((c) => c.symbol.toLowerCase().contains(q) || c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<void> toggleFavorite(String symbol) async {
    if (_favorites.contains(symbol)) {
      _favorites.remove(symbol);
    } else {
      _favorites.add(symbol);
    }
    _updateFavoriteFlags();
    await _saveFavorites();
  }

  @override
  Future<List<String>> getFavoriteSymbols() async {
    return _favorites.toList();
  }
}
