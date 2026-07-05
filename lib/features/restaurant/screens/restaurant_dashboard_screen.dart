import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/features/restaurant/providers/restaurant_orders_provider.dart';
import 'package:online_food_ordering/features/restaurant/widgets/admin_order_card.dart';

class RestaurantDashboardScreen extends ConsumerWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(restaurantOrdersProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Operational Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ordersAsync.when(
          data: (orders) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveHelper.getAdaptivePadding(context, mobileValue: 16, desktopValue: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatGrid(context, orders, primaryColor),
                const SizedBox(height: 40),
                _buildOrderSectionHeader(context, primaryColor),
                const SizedBox(height: 20),
                _buildOrdersView(context, ref, orders, isDesktop),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, List<OrderModel> orders, Color primaryColor) {
    // Only include successful or pending revenue, exclude cancelled
    final revenue = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, o) => sum + o.totalPrice);
    
    // Live orders are those that are NOT delivered AND NOT cancelled
    final liveOrdersCount = orders
        .where((o) => o.status != OrderStatus.handedToDriver && o.status != OrderStatus.cancelled)
        .length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(title: 'Revenue', value: '\$${revenue.toStringAsFixed(0)}', icon: Icons.payments_outlined, color: primaryColor),
        _StatCard(title: 'Live Orders', value: liveOrdersCount.toString(), icon: Icons.shopping_bag_outlined, color: Colors.orange),
        _StatCard(title: 'Completed', value: orders.where((o) => o.status == OrderStatus.handedToDriver).length.toString(), icon: Icons.check_circle_outline_rounded, color: Colors.green),
      ],
    );
  }

  Widget _buildOrderSectionHeader(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: primaryColor),
        const SizedBox(width: 12),
        const Text(
          'Live Incoming Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOrdersView(BuildContext context, WidgetRef ref, List<OrderModel> orders, bool isDesktop) {
    // Filter: Hide both delivered and cancelled orders from the live view
    final activeOrders = orders.where((o) => 
      o.status != OrderStatus.handedToDriver && 
      o.status != OrderStatus.cancelled
    ).toList();
    
    if (activeOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Text('No active orders right now.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 320,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) => AdminOrderCard(
          order: activeOrders[index],
          onStatusUpdate: (s) => ref.read(restaurantOrderActionsProvider).updateOrderStatus(activeOrders[index].id, s),
        ).animate().fadeIn(delay: (index * 50).ms),
      );
    }

    return Column(
      children: activeOrders.map((o) => AdminOrderCard(
        order: o,
        onStatusUpdate: (s) => ref.read(restaurantOrderActionsProvider).updateOrderStatus(o.id, s),
      ).animate().fadeIn()).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = ScreenBreakpoints.isMobile(context) ? (MediaQuery.sizeOf(context).width - 52) / 2 : 240.0;
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
