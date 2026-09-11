enum OrderType { market, limit, stopLimit }
enum OrderSide { buy, sell }
enum OrderStatus { open, filled, canceled, partial }

class OrderModel {
  final String id;
  final String pair;
  final OrderType type;
  final OrderSide side;
  final double price;
  final double? stopPrice;
  final double amount;
  final double filledAmount;
  final OrderStatus status;
  final DateTime dateTime;

  const OrderModel({
    required this.id,
    required this.pair,
    required this.type,
    required this.side,
    required this.price,
    this.stopPrice,
    required this.amount,
    required this.filledAmount,
    required this.status,
    required this.dateTime,
  });

  bool get isBuy => side == OrderSide.buy;
  double get total => price * amount;
  double get fillPercentage => amount > 0 ? (filledAmount / amount) * 100 : 0;

  OrderModel copyWith({
    String? id,
    String? pair,
    OrderType? type,
    OrderSide? side,
    double? price,
    double? stopPrice,
    double? amount,
    double? filledAmount,
    OrderStatus? status,
    DateTime? dateTime,
  }) {
    return OrderModel(
      id: id ?? this.id,
      pair: pair ?? this.pair,
      type: type ?? this.type,
      side: side ?? this.side,
      price: price ?? this.price,
      stopPrice: stopPrice ?? this.stopPrice,
      amount: amount ?? this.amount,
      filledAmount: filledAmount ?? this.filledAmount,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pair': pair,
      'type': type.name,
      'side': side.name,
      'price': price,
      'stopPrice': stopPrice,
      'amount': amount,
      'filledAmount': filledAmount,
      'status': status.name,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      pair: json['pair'] as String,
      type: OrderType.values.byName(json['type'] as String),
      side: OrderSide.values.byName(json['side'] as String),
      price: (json['price'] as num).toDouble(),
      stopPrice: json['stopPrice'] != null ? (json['stopPrice'] as num).toDouble() : null,
      amount: (json['amount'] as num).toDouble(),
      filledAmount: (json['filledAmount'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      dateTime: DateTime.parse(json['dateTime'] as String),
    );
  }
}
