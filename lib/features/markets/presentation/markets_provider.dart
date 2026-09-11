import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/coin_model.dart';
import '../home/presentation/home_provider.dart';

enum MarketCategory { favorites, all, usdt, topGainers, topLosers }
enum MarketSortField { name, price, change24h, volume }

class MarketFilterState {
  final MarketCategory category;
  final String searchQuery;
  final MarketSortField sortField;
  final bool isAscending;

  const MarketFilterState({
    this.category = MarketCategory.all,
    this.searchQuery = '',
    this.sortField = MarketSortField.volume,
    this.isAscending = false,
  });

  MarketFilterState copyWith({
    MarketCategory? category,
    String? searchQuery,
    MarketSortField? sortField,
    bool? isAscending,
  }) {
    return MarketFilterState(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

class MarketFilterNotifier extends StateNotifier<MarketFilterState> {
  MarketFilterNotifier() : super(const MarketFilterState());

  void setCategory(MarketCategory category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSort(MarketSortField field) {
    if (state.sortField == field) {
      state = state.copyWith(isAscending: !state.isAscending);
    } else {
      state = state.copyWith(sortField: field, isAscending: false);
    }
  }
}

final marketFilterProvider = StateNotifierProvider<MarketFilterNotifier, MarketFilterState>((ref) {
  return MarketFilterNotifier();
});

final filteredCoinsProvider = FutureProvider<List<CoinModel>>((ref) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  final filter = ref.watch(marketFilterProvider);
  List<CoinModel> coins = await marketRepo.getCoins();

  // Filter category
  switch (filter.category) {
    case MarketCategory.favorites:
      coins = coins.where((c) => c.isFavorite).toList();
      break;
    case MarketCategory.topGainers:
      coins = await marketRepo.getTopGainers();
      break;
    case MarketCategory.topLosers:
      coins = await marketRepo.getTopLosers();
      break;
    case MarketCategory.usdt:
    case MarketCategory.all:
      break;
  }

  // Search query
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    coins = coins.where((c) => c.symbol.toLowerCase().contains(query) || c.name.toLowerCase().contains(query)).toList();
  }

  // Sort
  coins.sort((a, b) {
    int compare = 0;
    switch (filter.sortField) {
      case MarketSortField.name:
        compare = a.name.compareTo(b.name);
        break;
      case MarketSortField.price:
        compare = a.currentPrice.compareTo(b.currentPrice);
        break;
      case MarketSortField.change24h:
        compare = a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h);
        break;
      case MarketSortField.volume:
        compare = a.volume24h.compareTo(b.volume24h);
        break;
    }
    return filter.isAscending ? compare : -compare;
  });

  return coins;
});
