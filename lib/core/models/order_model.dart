import 'cart_item_model.dart';

enum OrderStatus {
  waiting,
  confirmed,
  handedToDriver,
}

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double totalPrice;
  final DateTime timestamp;
  final OrderStatus status;
  final String estimatedTime;
  final String deliveryAddress;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.timestamp,
    required this.status,
    required this.estimatedTime,
    required this.deliveryAddress,
  });

  OrderModel copyWith({
    OrderStatus? status,
    String? estimatedTime,
  }) {
    return OrderModel(
      id: id,
      items: items,
      totalPrice: totalPrice,
      timestamp: timestamp,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      deliveryAddress: deliveryAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'estimatedTime': estimatedTime,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      items: List<CartItemModel>.from(
        (map['items'] as List).map((x) => CartItemModel.fromMap(x as Map<String, dynamic>)),
      ),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      status: OrderStatus.values.byName(map['status'] as String),
      estimatedTime: map['estimatedTime'] as String,
      deliveryAddress: map['deliveryAddress'] as String,
    );
  }
}
