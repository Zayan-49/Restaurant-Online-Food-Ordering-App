import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/features/customer/home/providers/favorites_provider.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/widgets/expandable_description.dart';
import 'package:online_food_ordering/routes/app_router.dart';
import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';

class FoodCard extends ConsumerWidget {
  const FoodCard({
    super.key,
    required this.food,
    this.heroTag,
  });

  final FoodModel food;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 8, tablet: 10, desktop: 12);
    final iconSize = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 18, desktop: 20);
    final buttonSize = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 28, tablet: 32, desktop: 36);

    final isFavorite = ref.watch(favoritesProvider).maybeWhen(
      data: (ids) => ids.contains(food.id),
      orElse: () => false,
    );

    final effectiveTag = heroTag ?? 'food_image_${food.id}';

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouteNames.productDetails,
        extra: food,
      ),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Image section with Premium Blend Mask
              Expanded(
                flex: 5,
                child: Hero(
                  tag: effectiveTag,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: food.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const FoodCardShimmer(),
                        errorWidget: (context, url, error) => Image.asset(
                          AppAssets.burgerPlaceholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // LUXURY BLEND: Bottom Gradient to soften the transition
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Favorite (Heart) Button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(food.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: isFavorite ? Colors.redAccent : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      // Rating badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${food.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Content section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleSmallFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ExpandableDescription(
                            text: food.description,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '\$${food.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: ResponsiveHelper.getTitleSmallFontSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).addItem(food);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${food.title} added to cart'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  width: 200,
                                ),
                              );
                            },
                            child: Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: iconSize,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
