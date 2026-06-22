import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/features/cart/widgets/cart_item_widget.dart';
import 'package:online_food_ordering/routes/app_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _EmptyCartState(padding: padding)
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getMaxWidth(context),
                  ),
                  child: ScreenBreakpoints.isDesktop(context) ||
                          ScreenBreakpoints.isLargeDesktop(context)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cart items list
                            Expanded(
                              flex: 2,
                              child: ListView.builder(
                                padding: EdgeInsets.all(padding),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return CartItemWidget(
                                    item: item,
                                    onIncrement: () => ref
                                        .read(cartProvider.notifier)
                                        .incrementQuantity(item.food.id),
                                    onDecrement: () => ref
                                        .read(cartProvider.notifier)
                                        .decrementQuantity(item.food.id),
                                    onRemove: () => ref
                                        .read(cartProvider.notifier)
                                        .removeItem(item.food.id),
                                  );
                                },
                              ),
                            ),
                            // Summary on the right for Desktop - using proportional width
                            Flexible(
                              flex: 1,
                              child: SingleChildScrollView(
                                child: _CartSummary(
                                  total: cartTotal,
                                  padding: padding,
                                  isDesktop: true,
                                  onCheckout: () => context
                                      .pushNamed(AppRouteNames.checkout),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // Cart items list
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.all(padding),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return CartItemWidget(
                                    item: item,
                                    onIncrement: () => ref
                                        .read(cartProvider.notifier)
                                        .incrementQuantity(item.food.id),
                                    onDecrement: () => ref
                                        .read(cartProvider.notifier)
                                        .decrementQuantity(item.food.id),
                                    onRemove: () => ref
                                        .read(cartProvider.notifier)
                                        .removeItem(item.food.id),
                                  );
                                },
                              ),
                            ),

                            // Summary and Checkout button
                            _CartSummary(
                              total: cartTotal,
                              padding: padding,
                              onCheckout: () =>
                                  context.pushNamed(AppRouteNames.checkout),
                            ),
                          ],
                        ),
                ),
              ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add some delicious food to your cart!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.total,
    required this.padding,
    required this.onCheckout,
    this.isDesktop = false,
  });

  final double total;
  final double padding;
  final VoidCallback onCheckout;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDesktop
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: isDesktop ? const Offset(0, 4) : const Offset(0, -4),
          ),
        ],
        border: isDesktop ? Border.all(color: Colors.grey.shade100) : null,
      ),
      margin: isDesktop ? EdgeInsets.all(padding) : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: padding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
