import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/core/models/cart_item_model.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(FoodModel food) {
    final existingIndex = state.indexWhere((item) => item.food.id == food.id);
    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItemModel(food: food, quantity: 1)];
    }
  }

  void removeItem(String foodId) {
    state = state.where((item) => item.food.id != foodId).toList();
  }

  void incrementQuantity(String foodId) {
    final index = state.indexWhere((item) => item.food.id == foodId);
    if (index != -1) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementQuantity(String foodId) {
    final index = state.indexWhere((item) => item.food.id == foodId);
    if (index != -1) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, index),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(foodId);
      }
    }
  }

  void clearCart() {
    state = [];
  }

  /// Places the order to Supabase and clears the cart on success.
  Future<String> placeOrder({
    required String address,
    required String phone,
    required String type,
    required double fee,
    required String estimatedTime,
  }) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) throw Exception('Please login to place an order');
    if (state.isEmpty) throw Exception('Your cart is empty');

    final total = state.fold(0.0, (sum, item) => sum + item.totalItemPrice);
    
    // Map cart items to OrderItemModel structure
    final orderItems = state.map((item) => OrderItemModel(
      food: item.food,
      quantity: item.quantity,
    )).toList();

    try {
      final response = await SupabaseConfig.client.from('orders').insert({
        'customer_id': user.id,
        'items': orderItems.map((x) => x.toMap()).toList(),
        'total_price': total,
        'delivery_fee': fee,
        'order_type': type,
        'phone_number': phone,
        'estimated_time': estimatedTime,
        'status': OrderStatus.waiting.name,
        'delivery_address': address,
      }).select().single();

      clearCart();
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.totalItemPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});
