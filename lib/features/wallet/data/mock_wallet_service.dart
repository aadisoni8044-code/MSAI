import '../../../shared/models/wallet_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../domain/wallet_repository.dart';

class MockWalletService implements WalletRepository {
  double _fiatBalance = 12450.00;
  List<WalletAsset> _assets = [
    const WalletAsset(
      symbol: 'BTC',
      name: 'Bitcoin',
      iconUrl: 'assets/icons/btc.png',
      quantity: 0.85,
      lockedQuantity: 0.15,
      currentPrice: 67450.25,
      priceChange24h: 3.45,
    ),
    const WalletAsset(
      symbol: 'ETH',
      name: 'Ethereum',
      iconUrl: 'assets/icons/eth.png',
      quantity: 4.20,
      lockedQuantity: 1.50,
      currentPrice: 3480.10,
      priceChange24h: -1.25,
    ),
    const WalletAsset(
      symbol: 'SOL',
      name: 'Solana',
      iconUrl: 'assets/icons/sol.png',
      quantity: 45.0,
      lockedQuantity: 0.0,
      currentPrice: 178.40,
      priceChange24h: 8.92,
    ),
    const WalletAsset(
      symbol: 'BNB',
      name: 'BNB',
      iconUrl: 'assets/icons/bnb.png',
      quantity: 12.0,
      lockedQuantity: 0.0,
      currentPrice: 585.60,
      priceChange24h: 2.15,
    ),
  ];

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'TX-1001',
      title: 'Deposit USDT',
      symbol: 'USDT',
      amount: 5000.0,
      valueUsd: 5000.0,
      type: TransactionType.deposit,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      id: 'TX-1002',
      title: 'Buy Bitcoin',
      symbol: 'BTC',
      amount: 0.05,
      valueUsd: 3372.5,
      type: TransactionType.buy,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TransactionModel(
      id: 'TX-1003',
      title: 'Withdraw SOL',
      symbol: 'SOL',
      amount: 10.0,
      valueUsd: 1784.0,
      type: TransactionType.withdraw,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<WalletModel> getWalletOverview() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return WalletModel(
      fiatBalance: _fiatBalance,
      cryptoAssets: _assets,
    );
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions;
  }

  @override
  Future<void> deposit(String symbol, double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (symbol == 'USDT' || symbol == 'USD') {
      _fiatBalance += amount;
    } else {
      final idx = _assets.indexWhere((a) => a.symbol == symbol);
      if (idx != -1) {
        final existing = _assets[idx];
        _assets[idx] = existing.copyWith(quantity: existing.quantity + amount);
      }
    }
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Deposit $symbol',
        symbol: symbol,
        amount: amount,
        valueUsd: amount,
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> withdraw(String symbol, double amount, String destinationAddress) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (symbol == 'USDT' || symbol == 'USD') {
      if (_fiatBalance < amount) throw Exception('Insufficient USDT balance');
      _fiatBalance -= amount;
    } else {
      final idx = _assets.indexWhere((a) => a.symbol == symbol);
      if (idx == -1 || _assets[idx].quantity < amount) {
        throw Exception('Insufficient $symbol balance');
      }
      final existing = _assets[idx];
      _assets[idx] = existing.copyWith(quantity: existing.quantity - amount);
    }
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Withdraw $symbol',
        symbol: symbol,
        amount: amount,
        valueUsd: amount,
        type: TransactionType.withdraw,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> transfer(String fromAccount, String toAccount, double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer $fromAccount -> $toAccount',
        symbol: 'USDT',
        amount: amount,
        valueUsd: amount,
        type: TransactionType.transfer,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
    );
  }
}
