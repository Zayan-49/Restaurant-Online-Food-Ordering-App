import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/routes/app_router.dart';

/// Home screen header with greeting and location.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, John',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: ResponsiveHelper.getHeadlineMediumFontSize(
                                context),
                          ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 4, tablet: 6, desktop: 8)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: ResponsiveHelper.getAdaptiveSize(context,
                              mobile: 14, tablet: 16, desktop: 18),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(
                            width: ResponsiveHelper.getAdaptiveSize(context,
                                mobile: 4, tablet: 6, desktop: 8)),
                        Flexible(
                          child: Text(
                            'New York, NY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: ResponsiveHelper
                                      .getBodyMediumFontSize(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                  width: ResponsiveHelper.getAdaptiveSize(context,
                      mobile: 12, tablet: 16, desktop: 20)),

              // Cart icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.pushNamed(AppRouteNames.cart),
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      size: ResponsiveHelper.getAdaptiveSize(context,
                          mobile: 24, tablet: 28, desktop: 32),
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
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
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
              ),

              SizedBox(
                  width: ResponsiveHelper.getAdaptiveSize(context,
                      mobile: 12, tablet: 16, desktop: 20)),
              CircleAvatar(
                radius: ResponsiveHelper.getAdaptiveSize(context,
                    mobile: 24, tablet: 28, desktop: 32),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  'JD',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize:
                            ResponsiveHelper.getTitleMediumFontSize(context),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

