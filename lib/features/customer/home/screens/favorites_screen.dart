import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/home/providers/favorites_provider.dart';
import 'package:online_food_ordering/features/customer/home/widgets/responsive_food_grid.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteFoods = ref.watch(favoriteFoodsProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: favoriteFoods.isEmpty
          ? _EmptyFavorites(padding: padding)
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                  child: ResponsiveFoodGrid(
                    foods: favoriteFoods,
                    heroTagPrefix: 'fav', // Unique prefix for favorites grid
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({super.key, required this.padding});
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the heart icon on any dish to save it here for later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
