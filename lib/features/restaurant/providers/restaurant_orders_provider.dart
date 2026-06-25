import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/core/models/cart_item_model.dart';

/// MOCK DATA FOR UI DEVELOPMENT (No Backend Yet)
final restaurantOrdersProvider = NotifierProvider<RestaurantOrdersNotifier, List<OrderModel>>(RestaurantOrdersNotifier.new);

class RestaurantOrdersNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    return [
      OrderModel(
        id: 'ORD-1001',
        items: [
          CartItemModel(
            food: const FoodModel(id: '1', title: 'Premium Beef Burger', price: 18.99, description: '', category: 'Burgers', imageUrl: '', rating: 4.8, reviewCount: 100),
            quantity: 2,
          ),
        ],
        totalPrice: 37.98,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: OrderStatus.waiting,
        estimatedTime: '25-30 mins',
        deliveryAddress: '123 Luxury Lane, NY',
      ),
      OrderModel(
        id: 'ORD-1002',
        items: [
          CartItemModel(
            food: const FoodModel(id: '4', title: 'Margherita Pizza', price: 16.99, description: '', category: 'Pizza', imageUrl: '', rating: 4.9, reviewCount: 100),
            quantity: 1,
          ),
        ],
        totalPrice: 16.99,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: OrderStatus.confirmed,
        estimatedTime: '15 mins',
        deliveryAddress: '456 Elite Ave, NY',
      ),
    ];
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: status)
        else
          order,
    ];
  }
}

/// Provider to handle order actions in UI
final restaurantOrderActionsProvider = Provider((ref) {
  return ref.read(restaurantOrdersProvider.notifier);
});
