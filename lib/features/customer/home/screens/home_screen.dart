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
          _HomeBody(key: const PageStorageKey('home_main_body')), 
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
  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);
    
    // 1. Get filtered list (which is now stable even during background loads)
    final foods = ref.watch(filteredFoodsProvider);
    
    // 2. ONLY show initial loading if the list is empty AND the stream is actually loading
    final isStreamLoading = ref.watch(allFoodsStreamProvider).isLoading;
    final showShimmers = isStreamLoading && foods.isEmpty;

    final selectedCat = ref.watch(selectedCategoryProvider);

    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey('home_scroll_view'),
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
                CategoryModel(id: 'Deals', name: 'Deals'),
                CategoryModel(id: 'Burgers', name: 'Burgers'),
                CategoryModel(id: 'Pizza', name: 'Pizza'),
                CategoryModel(id: 'BBQ', name: 'BBQ'),
                CategoryModel(id: 'Desserts', name: 'Desserts'),
                CategoryModel(id: 'Drinks', name: 'Drinks'),
              ],
              onCategorySelected: (cat) => ref.read(selectedCategoryProvider.notifier).state = cat,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          if (showShimmers)
            SliverPadding(
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
            )
          else if (foods.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverToBoxAdapter(
                child: ResponsiveFoodGrid(
                  foods: foods,
                  heroTagPrefix: 'home_grid', 
                ),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No results found.'),
              )),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
