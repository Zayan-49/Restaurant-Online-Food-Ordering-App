import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/customer/orders/providers/orders_providers.dart';
import 'package:online_food_ordering/features/customer/orders/widgets/order_tracker_widget.dart';
import 'package:online_food_ordering/features/customer/orders/widgets/order_details_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrder = ref.watch(activeOrderProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: activeOrder == null
            ? _NoActiveOrder(padding: padding)
            : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getMaxWidth(context),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: ScreenBreakpoints.isDesktop(context) ||
                              ScreenBreakpoints.isLargeDesktop(context)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Animated Tracker
                                      OrderTrackerWidget(
                                          status: activeOrder.status),
                                      const SizedBox(height: 24),
                                      // Support Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(
                                              Icons.chat_bubble_outline_rounded),
                                          label: const Text('Contact Support'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 3,
                                  child: // Order Details
                                      OrderDetailsCard(order: activeOrder),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                // Animated Tracker
                                OrderTrackerWidget(status: activeOrder.status),
                                SizedBox(height: padding),

                                // Order Details
                                OrderDetailsCard(order: activeOrder),
                                SizedBox(height: padding * 2),

                                // Support Button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                        Icons.chat_bubble_outline_rounded),
                                    label: const Text('Contact Support'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _NoActiveOrder extends StatelessWidget {
  const _NoActiveOrder({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Orders',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You don\'t have any orders being tracked right now.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }
}
