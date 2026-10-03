import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/providers/order_history_provider.dart';
import 'package:online_food_ordering/features/customer/orders/widgets/order_details_card.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(orderHistoryProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchHeader(ref, padding),
          Expanded(
            child: historyAsync.when(
              data: (orders) {
                if (orders.isEmpty) return _buildEmptyState();
                
                return ListView.builder(
                  padding: EdgeInsets.all(padding),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _HistoryTile(order: order).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.05);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading history: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(WidgetRef ref, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      color: Colors.white,
      child: TextField(
        onChanged: (v) => ref.read(historySearchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Search by Order ID or Dish...',
          prefixIcon: const Icon(Icons.search_rounded),
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('No records found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // FIXED: Used tilePadding instead of contentPadding
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 20),
          ),
          title: Text(
            'Order #${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${order.totalPrice.toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              _StatusBadge(status: order.status),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: OrderDetailsCard(order: order),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;
    String label = 'Pending';

    if (status == OrderStatus.handedToDriver) {
      color = Colors.green;
      label = 'Delivered';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
