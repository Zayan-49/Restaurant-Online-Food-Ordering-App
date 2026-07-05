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
    final isTakeaway = order.orderType == 'takeaway';

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
            // Status Banner with Order Type
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
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isTakeaway ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isTakeaway ? 'TAKEAWAY' : 'DELIVERY',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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
                  // Customer Contact Info
                  Row(
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        order.phoneNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  if (!isTakeaway) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const Divider(height: 32),
                  
                  // Items Section
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
                        '\$${(order.totalPrice + order.deliveryFee).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons (Confirm/Ready & Cancel)
                  if (order.status != OrderStatus.handedToDriver && order.status != OrderStatus.cancelled)
                    Row(
                      children: [
                        // Main Action Button
                        Expanded(
                          flex: 3,
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
                        const SizedBox(width: 12),
                        // Cancel Button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => _showCancelDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep It')),
          ElevatedButton(
            onPressed: () {
              onStatusUpdate(OrderStatus.cancelled);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
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
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  OrderStatus _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.waiting:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.handedToDriver;
      default:
        return current;
    }
  }

  String _getActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.waiting:
        return 'Confirm';
      case OrderStatus.confirmed:
        return 'Mark Ready';
      default:
        return 'Done';
    }
  }
}
