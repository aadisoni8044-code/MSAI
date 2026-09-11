import '../../../shared/models/wallet_model.dart';
import '../../../shared/models/transaction_model.dart';

abstract class WalletRepository {
  Future<WalletModel> getWalletOverview();
  Future<List<TransactionModel>> getRecentTransactions();
  Future<void> deposit(String symbol, double amount);
  Future<void> withdraw(String symbol, double amount, String destinationAddress);
  Future<void> transfer(String fromAccount, String toAccount, double amount);
}
