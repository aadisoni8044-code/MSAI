import '../../../shared/models/coin_model.dart';
import '../../../shared/models/candlestick_model.dart';

abstract class MarketRepository {
  Future<List<CoinModel>> getCoins();
  Future<CoinModel?> getCoinBySymbol(String symbol);
  Future<List<CandlestickModel>> getCandlesticks(String symbol, String timeframe);
  Future<List<CoinModel>> getTopGainers();
  Future<List<CoinModel>> getTopLosers();
  Future<List<CoinModel>> searchCoins(String query);
  Future<void> toggleFavorite(String symbol);
  Future<List<String>> getFavoriteSymbols();
}
