import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/customer/orders/providers/customer_orders_provider.dart';
import 'package:online_food_ordering/features/customer/orders/widgets/order_tracker_widget.dart';
import 'package:online_food_ordering/features/customer/orders/widgets/order_details_card.dart';
import 'package:online_food_ordering/core/models/order_model.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(activeOrdersStreamProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('Live Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: activeOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) return _NoActiveOrder(padding: padding);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: List.generate(orders.length, (index) {
                        final order = orders[index];
                        final isCompleted = order.status == OrderStatus.handedToDriver;
                        final isCancelled = order.status == OrderStatus.cancelled;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OrderHeader(order: order, isCompleted: isCompleted, isCancelled: isCancelled),
                              const SizedBox(height: 16),
                              
                              if (ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          if (isCancelled) _CancelledStateCard(order: order)
                                          else if (isCompleted) _CompletedStateCard(order: order)
                                          else OrderTrackerWidget(status: order.status),
                                          const SizedBox(height: 24),
                                          _ContactSupportButton(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 3, child: OrderDetailsCard(order: order)),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    if (isCancelled) _CancelledStateCard(order: order)
                                    else if (isCompleted) _CompletedStateCard(order: order)
                                    else OrderTrackerWidget(status: order.status),
                                    SizedBox(height: padding),
                                    OrderDetailsCard(order: order),
                                    const SizedBox(height: 24),
                                    _ContactSupportButton(),
                                  ],
                                ),
                              
                              if (index < orders.length - 1) 
                                const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Divider(height: 1, thickness: 1, color: Colors.black12),
                                ),
                            ],
                          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.05),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _OrderHeader extends ConsumerWidget {
  const _OrderHeader({required this.order, required this.isCompleted, required this.isCancelled});
  final OrderModel order;
  final bool isCompleted;
  final bool isCancelled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle;
    Color subtitleColor = Colors.grey;

    if (isCancelled) {
      subtitle = 'Order was cancelled';
      subtitleColor = Colors.redAccent;
    } else if (isCompleted) {
      subtitle = 'Delivered successfully';
      subtitleColor = Colors.green;
    } else {
      subtitle = 'Arriving in ${order.estimatedTime}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORDER #${order.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            Text(
              subtitle,
              style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: isCancelled ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
        if (isCompleted || isCancelled)
          IconButton(
            onPressed: () {
              ref.read(dismissedOrdersProvider.notifier).update((set) => {...set, order.id});
            },
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            tooltip: 'Dismiss from tracking',
          ),
      ],
    );
  }
}

class _CompletedStateCard extends StatelessWidget {
  const _CompletedStateCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
          SizedBox(height: 16),
          Text(
            'Order Delivered!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
          ),
          Text(
            'Enjoy your meal. Rate us on the history screen.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CancelledStateCard extends StatelessWidget {
  const _CancelledStateCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 48),
          SizedBox(height: 16),
          Text(
            'Order Cancelled',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
          ),
          Text(
            'Sorry, your order could not be fulfilled at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ContactSupportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Contact Support'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('No Live Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          const Text('Check your Order History for past purchases.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Back to Home')),
        ],
      ),
    );
  }
}
