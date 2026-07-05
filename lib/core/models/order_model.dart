import 'food_model.dart';

enum OrderStatus {
  waiting,
  confirmed,
  handedToDriver,
  cancelled; // Added cancelled state

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.waiting,
    );
  }
}

class OrderItemModel {
  final FoodModel food;
  final int quantity;

  OrderItemModel({
    required this.food,
    required this.quantity,
  });

  double get totalItemPrice => food.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'food': food.toMap(),
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      food: FoodModel.fromMap(map['food'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final List<OrderItemModel> items;
  final double totalPrice;
  final double deliveryFee;
  final String orderType;
  final String phoneNumber;
  final OrderStatus status;
  final String deliveryAddress;
  final String estimatedTime;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalPrice,
    required this.deliveryFee,
    required this.orderType,
    required this.phoneNumber,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedTime = '30-40 min',
  });

  OrderModel copyWith({
    String? id,
    String? customerId,
    List<OrderItemModel>? items,
    double? totalPrice,
    double? deliveryFee,
    String? orderType,
    String? phoneNumber,
    OrderStatus? status,
    String? deliveryAddress,
    String? estimatedTime,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      orderType: orderType ?? this.orderType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'items': items.map((x) => x.toMap()).toList(),
      'total_price': totalPrice,
      'delivery_fee': deliveryFee,
      'order_type': orderType,
      'phone_number': phoneNumber,
      'status': status.name,
      'delivery_address': deliveryAddress,
      'estimated_time': estimatedTime,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      customerId: map['customer_id']?.toString() ?? '',
      items: (map['items'] as List<dynamic>)
          .map((x) => OrderItemModel.fromMap(x as Map<String, dynamic>))
          .toList(),
      totalPrice: (map['total_price'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      orderType: map['order_type'] ?? 'delivery',
      phoneNumber: map['phone_number'] ?? '',
      status: OrderStatus.fromString(map['status'] as String),
      deliveryAddress: map['delivery_address'] ?? 'Takeaway',
      estimatedTime: map['estimated_time']?.toString() ?? '30-40 min',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
