import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';

/// Tracks IDs of orders that the user manually dismissed (X clicked).
final dismissedOrdersProvider = StateProvider<Set<String>>((ref) => {});

/// Fetches ALL active orders for the current user with caching.
final activeOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  ref.keepAlive(); // Cache enabled
  final user = SupabaseConfig.client.auth.currentUser;
  final dismissedIds = ref.watch(dismissedOrdersProvider);
  
  if (user == null) return Stream.value([]);

  return SupabaseConfig.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('customer_id', user.id)
      .order('created_at', ascending: false)
      .map((data) {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        return data.map((map) => OrderModel.fromMap(map)).where((order) {
          if (dismissedIds.contains(order.id)) return false;
          if (order.status == OrderStatus.handedToDriver || order.status == OrderStatus.cancelled) {
            return order.createdAt.isAfter(startOfToday);
          }
          return true;
        }).toList();
      });
});

final lastOrderIdProvider = StateProvider<String?>((ref) => null);
