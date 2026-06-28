import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/providers/restaurant_profile_provider.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/routes/app_router.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProfileProvider);
    final isOpen = restaurant.isCurrentlyOpen;
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getAdaptiveSize(context,
            mobile: 16, tablet: 20, desktop: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 1. Restaurant Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AppAssets.logo,
                  width: ResponsiveHelper.getAdaptiveSize(context, mobile: 44, desktop: 52),
                  height: ResponsiveHelper.getAdaptiveSize(context, mobile: 44, desktop: 52),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              
              // 2. Restaurant Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.getTitleLargeFontSize(context),
                              ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(isOpen: isOpen),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            restaurant.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Cart Icon with Badge
              _HeaderCartIcon(cartItemCount: cartItemCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: isOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCartIcon extends StatelessWidget {
  const _HeaderCartIcon({required this.cartItemCount});
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.pushNamed(AppRouteNames.cart),
          icon: Icon(
            Icons.shopping_cart_outlined,
            size: ResponsiveHelper.getAdaptiveSize(context,
                mobile: 24, tablet: 28, desktop: 30),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
