import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';

/// Real-time provider that streams all incoming orders for the Admin Dashboard.
final restaurantOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return SupabaseConfig.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false) // Show newest orders first
      .map((data) => data.map((map) => OrderModel.fromMap(map)).toList());
});

/// Actions provider for Admin to update order statuses.
final restaurantOrderActionsProvider = Provider((ref) => RestaurantOrderActions());

class RestaurantOrderActions {
  final _supabase = SupabaseConfig.client;

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _supabase.from('orders').update({
        'status': newStatus.name,
      }).eq('id', orderId);
    } catch (e) {throw Exception('Failed to update order status: $e');
    }
  }
}
