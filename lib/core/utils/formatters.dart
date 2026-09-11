import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _preciseCurrencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 4,
  );

  static String currency(num amount, {int decimals = 2}) {
    if (amount.abs() < 0.01 && amount != 0) {
      return _preciseCurrencyFormatter.format(amount);
    }
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  static String number(num amount, {int decimals = 2}) {
    final formatter = NumberFormat.decimalPattern()..maximumFractionDigits = decimals;
    return formatter.format(amount);
  }

  static String percentage(double percent) {
    final prefix = percent >= 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }

  static String compactVolume(double volume) {
    if (volume >= 1e9) {
      return '\$${(volume / 1e9).toStringAsFixed(2)}B';
    } else if (volume >= 1e6) {
      return '\$${(volume / 1e6).toStringAsFixed(2)}M';
    } else if (volume >= 1e3) {
      return '\$${(volume / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${volume.toStringAsFixed(2)}';
  }

  static String dateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String shortTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }
}
