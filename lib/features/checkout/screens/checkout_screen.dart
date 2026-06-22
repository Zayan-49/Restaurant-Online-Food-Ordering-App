import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/features/orders/models/order_models.dart';
import 'package:online_food_ordering/features/orders/providers/orders_providers.dart';
import 'package:online_food_ordering/routes/app_router.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CheckoutSection(
                                  title: 'Delivery Address',
                                  icon: Icons.location_on_outlined,
                                  child: const _AddressInfo(),
                                ),
                                SizedBox(height: padding),
                                _CheckoutSection(
                                  title: 'Payment Method',
                                  icon: Icons.payment_outlined,
                                  child: const _PaymentInfo(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: padding),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _CheckoutSection(
                                  title: 'Order Summary',
                                  icon: Icons.receipt_long_outlined,
                                  child: _OrderSummary(
                                    items: cartItems,
                                    total: cartTotal,
                                  ),
                                ),
                                SizedBox(height: padding),
                                _PlaceOrderButton(
                                  onPressed: () =>
                                      _showOrderSuccessDialog(context, ref),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CheckoutSection(
                            title: 'Delivery Address',
                            icon: Icons.location_on_outlined,
                            child: const _AddressInfo(),
                          ),
                          SizedBox(height: padding),
                          _CheckoutSection(
                            title: 'Payment Method',
                            icon: Icons.payment_outlined,
                            child: const _PaymentInfo(),
                          ),
                          SizedBox(height: padding),
                          _CheckoutSection(
                            title: 'Order Summary',
                            icon: Icons.receipt_long_outlined,
                            child: _OrderSummary(
                              items: cartItems,
                              total: cartTotal,
                            ),
                          ),
                          SizedBox(height: padding * 2),
                          _PlaceOrderButton(
                            onPressed: () =>
                                _showOrderSuccessDialog(context, ref),
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

  void _showOrderSuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your delicious food is being prepared and will be delivered soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newOrder = OrderModel(
                    id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                    items: List.from(ref.read(cartProvider)),
                    totalPrice: ref.read(cartTotalProvider),
                    timestamp: DateTime.now(),
                    status: OrderStatus.waiting,
                    estimatedTime: '30-35 mins',
                    deliveryAddress: '123 Luxury Lane, Suite 456, NY',
                  );

                  ref.read(activeOrderProvider.notifier).placeOrder(newOrder);
                  ref.read(cartProvider.notifier).clearCart();
                  
                  context.goNamed(AppRouteNames.orders);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Place Order',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _AddressInfo extends StatelessWidget {
  const _AddressInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'John Doe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          '123 Luxury Lane, Suite 456\nNew York, NY 10001\nUnited States',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }
}

class _PaymentInfo extends StatelessWidget {
  const _PaymentInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.credit_card_rounded, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visa Classic',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '**** **** **** 1234',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Change'),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.items,
    required this.total,
  });

  final List<dynamic> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.quantity}x ${item.food.title}'),
                  Text('\$${(item.food.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            )),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery Fee'),
            const Text('\$5.00'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '\$${(total + 5).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
