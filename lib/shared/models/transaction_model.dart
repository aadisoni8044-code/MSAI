enum TransactionType { deposit, withdraw, buy, sell, transfer }
enum TransactionStatus { completed, pending, failed }

class TransactionModel {
  final String id;
  final String title;
  final String symbol;
  final double amount;
  final double valueUsd;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.symbol,
    required this.amount,
    required this.valueUsd,
    required this.type,
    required this.status,
    required this.timestamp,
  });
}
