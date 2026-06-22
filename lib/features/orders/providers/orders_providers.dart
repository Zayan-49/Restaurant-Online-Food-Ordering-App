import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_models.dart';

final activeOrderProvider = NotifierProvider<ActiveOrderNotifier, OrderModel?>(ActiveOrderNotifier.new);

class ActiveOrderNotifier extends Notifier<OrderModel?> {
  Timer? _simulationTimer;

  @override
  OrderModel? build() {
    return null;
  }

  void placeOrder(OrderModel order) {
    state = order;
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    
    // Simulate progression
    _simulationTimer = Timer(const Duration(seconds: 5), () {
      if (state != null) {
        state = state!.copyWith(
          status: OrderStatus.confirmed,
          estimatedTime: '20-25 mins',
        );
        
        _simulationTimer = Timer(const Duration(seconds: 7), () {
          if (state != null) {
            state = state!.copyWith(
              status: OrderStatus.handedToDriver,
              estimatedTime: '15 mins',
            );
          }
        });
      }
    });
  }

  void clearActiveOrder() {
    _simulationTimer?.cancel();
    state = null;
  }
}
