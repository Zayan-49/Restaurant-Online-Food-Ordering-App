import 'package:online_food_ordering/features/cart/models/cart_item_model.dart';

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
}
