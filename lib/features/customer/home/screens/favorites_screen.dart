import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/home/providers/favorites_provider.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';
import 'package:online_food_ordering/features/customer/home/widgets/responsive_food_grid.dart';

import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteFoods = ref.watch(favoriteFoodsProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, 
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      body: SafeArea(
        child: favoriteFoods.isEmpty
            ? _buildEmptyState(context, ref)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.getMaxWidth(context),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: padding,
                            left: padding,
                            right: padding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Favorites',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveHelper.getHeadlineMediumFontSize(context),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your most loved luxury dishes in one place.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                      fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                                    ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.getMaxWidth(context),
                        ),
                        child: ResponsiveFoodGrid(foods: favoriteFoods),
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Luxury Heart Lottie Animation with Error Handling
            Lottie.network(
              'https://lottie.host/80f7574b-5777-4977-8c3b-558296d97e75/T5M8W8n3Xf.json',
              height: 250,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                // Fallback UI if network fails (prevents Red Box)
                return Column(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 10),
                    const Text('Unable to load animation'),
                  ],
                );
              },
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return const SizedBox(
                    height: 250,
                    child: AppLoader(),
                  );
                }
                return child;
              },
            ),
            const SizedBox(height: 32),
            Text(
              'No Favorites Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getTitleLargeFontSize(context),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your favorite products to see them here and order them anytime!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 0;
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Go Shopping',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
