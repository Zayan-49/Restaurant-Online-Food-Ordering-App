import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';
import 'package:online_food_ordering/features/customer/home/widgets/category_selector.dart';
import 'package:online_food_ordering/features/customer/home/widgets/home_header.dart';
import 'package:online_food_ordering/features/customer/home/widgets/home_search_bar.dart';
import 'package:online_food_ordering/features/customer/home/widgets/promo_banner.dart';
import 'package:online_food_ordering/features/customer/home/widgets/responsive_food_grid.dart';
import 'package:online_food_ordering/features/customer/home/screens/favorites_screen.dart';
import 'package:online_food_ordering/features/customer/profile/screens/profile_screen.dart';
import 'package:online_food_ordering/features/customer/orders/screens/orders_screen.dart';
import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: IndexedStack(
        index: bottomNavIndex,
        children: [
          const _HomeBody(),
          const FavoritesScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomNavIndex,
        onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);
    final foodsAsync = ref.watch(allFoodsProvider);
    final filteredFoods = ref.watch(filteredFoodsProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: HomeHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(child: HomeSearchBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(child: PromoBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          SliverToBoxAdapter(
            child: CategorySelector(
              selectedCategory: selectedCat,
              categories: const [
                CategoryModel(id: 'all', name: 'All'),
                CategoryModel(id: 'burgers', name: 'Burgers'),
                CategoryModel(id: 'pizza', name: 'Pizza'),
                CategoryModel(id: 'bbq', name: 'BBQ'),
                CategoryModel(id: 'desserts', name: 'Desserts'),
                CategoryModel(id: 'drinks', name: 'Drinks'),
              ],
              onCategorySelected: (cat) => ref.read(selectedCategoryProvider.notifier).state = cat,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          foodsAsync.when(
            data: (_) => SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverToBoxAdapter(
                child: ResponsiveFoodGrid(foods: filteredFoods),
              ),
            ),
            loading: () => SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ScreenBreakpoints.isMobile(context) ? 2 : 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const FoodCardShimmer(),
                  childCount: 6,
                ),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
