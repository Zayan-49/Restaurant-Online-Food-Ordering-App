import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/providers/restaurant_profile_provider.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/features/customer/cart/widgets/cart_item_widget.dart';
import 'package:online_food_ordering/routes/app_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final restaurantAsync = ref.watch(restaurantProfileProvider);
    
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
            : restaurantAsync.when(
                data: (restaurant) {
                  final canCheckout = cartTotal >= restaurant.minOrderValue && restaurant.isCurrentlyOpen;
                  
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveHelper.getMaxWidth(context),
                      ),
                      child: ScreenBreakpoints.isDesktop(context) ||
                              ScreenBreakpoints.isLargeDesktop(context)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildCartList(cartItems, padding, ref),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: SingleChildScrollView(
                                    child: _CartSummary(
                                      total: cartTotal,
                                      padding: padding,
                                      isDesktop: true,
                                      canCheckout: canCheckout,
                                      minOrder: restaurant.minOrderValue,
                                      isClosed: !restaurant.isCurrentlyOpen,
                                      onCheckout: () => context.pushNamed(AppRouteNames.checkout),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(child: _buildCartList(cartItems, padding, ref)),
                                _CartSummary(
                                  total: cartTotal,
                                  padding: padding,
                                  canCheckout: canCheckout,
                                  minOrder: restaurant.minOrderValue,
                                  isClosed: !restaurant.isCurrentlyOpen,
                                  onCheckout: () => context.pushNamed(AppRouteNames.checkout),
                                ),
                              ],
                            ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error loading business rules: $e')),
              ),
      ),
    );
  }

  Widget _buildCartList(List<dynamic> items, double padding, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemWidget(
          item: item,
          onIncrement: () => ref.read(cartProvider.notifier).incrementQuantity(item.food.id),
          onDecrement: () => ref.read(cartProvider.notifier).decrementQuantity(item.food.id),
          onRemove: () => ref.read(cartProvider.notifier).removeItem(item.food.id),
        );
      },
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
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => context.pop(), child: const Text('Go Back')),
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
    required this.canCheckout,
    required this.minOrder,
    required this.isClosed,
    this.isDesktop = false,
  });

  final double total;
  final double padding;
  final VoidCallback onCheckout;
  final bool canCheckout;
  final double minOrder;
  final bool isClosed;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDesktop ? BorderRadius.circular(24) : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: isDesktop ? const Offset(0, 4) : const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isClosed) ...[
            _WarningBanner(message: 'Restaurant is currently CLOSED'),
            const SizedBox(height: 12),
          ] else if (total < minOrder) ...[
            _WarningBanner(message: 'Min. order value is \$${minOrder.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Price', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          SizedBox(height: padding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCheckout ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canCheckout ? primaryColor : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
