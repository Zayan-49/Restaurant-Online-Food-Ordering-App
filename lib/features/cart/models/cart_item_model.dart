import 'package:online_food_ordering/features/home/models/food_model.dart';

/// Model representing an item in the cart.
class CartItemModel {
  final FoodModel food;
  final int quantity;

  const CartItemModel({
    required this.food,
    required this.quantity,
  });

  /// Copy with helper for immutability.
  CartItemModel copyWith({
    FoodModel? food,
    int? quantity,
  }) {
    return CartItemModel(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Total price for this specific cart item.
  double get totalItemPrice => food.price * quantity;
}
