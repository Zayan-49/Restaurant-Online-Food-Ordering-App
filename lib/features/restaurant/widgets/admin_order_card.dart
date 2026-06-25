import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/models/order_model.dart';

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  final OrderModel order;
  final Function(OrderStatus) onStatusUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: statusColor.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${order.id.substring(order.id.length - 4)}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Items Section - Using Column instead of ListView for stability in nested scrolls
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text('${item.quantity}x ',
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Text(item.food.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      )),
                  
                  const Divider(height: 32),
                  
                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Revenue',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        '\$${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Button
                  if (order.status != OrderStatus.handedToDriver)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            onStatusUpdate(_getNextStatus(order.status)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(_getActionLabel(order.status),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waiting:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.handedToDriver:
        return Colors.green;
    }
  }

  OrderStatus _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.waiting:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.handedToDriver;
      case OrderStatus.handedToDriver:
        return OrderStatus.handedToDriver;
    }
  }

  String _getActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.waiting:
        return 'Confirm Order';
      case OrderStatus.confirmed:
        return 'Mark as Ready';
      case OrderStatus.handedToDriver:
        return 'Completed';
    }
  }
}
