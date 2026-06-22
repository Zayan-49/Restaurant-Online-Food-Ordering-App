import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/features/cart/models/cart_item_model.dart';
import 'package:online_food_ordering/features/home/models/food_model.dart';

/// Provider for the cart state.
final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);

/// Notifier to manage cart operations.
class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() {
    return [];
  }

  void addItem(FoodModel food) {
    final existingIndex = state.indexWhere((item) => item.food.id == food.id);
    if (existingIndex != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItemModel(food: food, quantity: 1)];
    }
  }

  void removeItem(String foodId) {
    state = state.where((item) => item.food.id != foodId).toList();
  }

  void incrementQuantity(String foodId) {
    state = [
      for (final item in state)
        if (item.food.id == foodId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrementQuantity(String foodId) {
    final item = state.firstWhere((item) => item.food.id == foodId);
    if (item.quantity > 1) {
      state = [
        for (final item in state)
          if (item.food.id == foodId)
            item.copyWith(quantity: item.quantity - 1)
          else
            item,
      ];
    } else {
      removeItem(foodId);
    }
  }

  void clearCart() {
    state = [];
  }
}

/// Provider for the total price of all items in the cart.
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + item.totalItemPrice);
});

/// Provider for the total count of items in the cart.
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (count, item) => count + item.quantity);
});
