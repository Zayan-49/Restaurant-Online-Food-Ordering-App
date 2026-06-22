import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/order_model.dart';

/// Provider to listen to all orders in real-time (for Restaurant Admin)
final restaurantOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  });
});

/// Notifier to handle order actions
final restaurantOrderActionsProvider = Provider((ref) => RestaurantOrderActions());

class RestaurantOrderActions {
  final _db = FirebaseFirestore.instance;

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }
}
