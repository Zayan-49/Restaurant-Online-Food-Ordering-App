import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/features/restaurant/providers/restaurant_orders_provider.dart';
import 'package:online_food_ordering/features/restaurant/widgets/admin_order_card.dart';

class RestaurantDashboardScreen extends ConsumerStatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  ConsumerState<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends ConsumerState<RestaurantDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(restaurantOrdersProvider);
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      // App Bar with Theme Color and proper Top SafeArea
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Elite Restaurant Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar remains for Desktop
          if (isDesktop) _buildSidebar(context, primaryColor),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveHelper.getAdaptivePadding(context, mobileValue: 16, desktopValue: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatGrid(context, orders, primaryColor),
                      const SizedBox(height: 40),
                      _buildOrderSectionHeader(context, primaryColor),
                      const SizedBox(height: 20),
                      _buildOrdersView(context, orders, isDesktop),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, Color primaryColor) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', isSelected: _selectedTabIndex == 0, onTap: () => setState(() => _selectedTabIndex = 0)),
          _SidebarItem(icon: Icons.list_alt_rounded, label: 'Live Orders', isSelected: _selectedTabIndex == 1, onTap: () => setState(() => _selectedTabIndex = 1)),
          _SidebarItem(icon: Icons.restaurant_rounded, label: 'Menu Editor', isSelected: _selectedTabIndex == 2, onTap: () => setState(() => _selectedTabIndex = 2)),
          _SidebarItem(icon: Icons.analytics_outlined, label: 'Analytics', isSelected: _selectedTabIndex == 3, onTap: () => setState(() => _selectedTabIndex = 3)),
          const Spacer(),
          _SidebarItem(icon: Icons.logout_rounded, label: 'Sign Out', isSelected: false, onTap: () {}, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, List<OrderModel> orders, Color primaryColor) {
    final revenue = orders.fold(0.0, (sum, o) => sum + o.totalPrice);
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(title: 'Revenue', value: '\$${revenue.toStringAsFixed(0)}', icon: Icons.payments_outlined, color: primaryColor),
        _StatCard(title: 'Orders', value: orders.length.toString(), icon: Icons.shopping_bag_outlined, color: Colors.orange),
        _StatCard(title: 'Rating', value: '4.9', icon: Icons.star_outline_rounded, color: Colors.blue),
      ],
    );
  }

  Widget _buildOrderSectionHeader(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Live Incoming Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildOrdersView(BuildContext context, List<OrderModel> orders, bool isDesktop) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Text('No orders yet.', style: TextStyle(color: Colors.grey)),
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
        itemCount: orders.length,
        itemBuilder: (context, index) => AdminOrderCard(
          order: orders[index],
          onStatusUpdate: (s) => ref.read(restaurantOrderActionsProvider).updateOrderStatus(orders[index].id, s),
        ).animate().fadeIn(delay: (200 + (index * 50)).ms).scale(begin: const Offset(0.95, 0.95)),
      );
    }

    return Column(
      children: orders.map((o) => AdminOrderCard(
        order: o,
        onStatusUpdate: (s) => ref.read(restaurantOrderActionsProvider).updateOrderStatus(o.id, s),
      ).animate().fadeIn().slideY(begin: 0.1)).toList(),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, required this.isSelected, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        leading: Icon(icon, color: isSelected ? primaryColor : (color ?? Colors.grey.shade600), size: 22),
        title: Text(
          label, 
          style: TextStyle(
            color: isSelected ? primaryColor : (color ?? Colors.grey.shade800), 
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          )
        ),
        dense: true,
      ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
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
