import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  final int quantity;

  const CartItemModel({
    required this.food,
    required this.quantity,
  });

  CartItemModel copyWith({
    FoodModel? food,
    int? quantity,
  }) {
    return CartItemModel(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalItemPrice => food.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'food': food.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      food: FoodModel.fromMap(map['food'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }
}
