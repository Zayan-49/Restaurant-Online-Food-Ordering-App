import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';
import 'package:online_food_ordering/features/customer/home/widgets/home_header.dart';
import 'package:online_food_ordering/features/customer/home/widgets/home_search_bar.dart';
import 'package:online_food_ordering/features/customer/home/widgets/promo_banner.dart';
import 'package:online_food_ordering/features/customer/home/widgets/category_selector.dart';
import 'package:online_food_ordering/features/customer/home/widgets/responsive_food_grid.dart';
import 'package:online_food_ordering/features/customer/home/widgets/custom_bottom_navbar.dart';
import 'package:online_food_ordering/features/customer/home/widgets/section_title.dart';
import 'package:online_food_ordering/features/customer/home/screens/favorites_screen.dart';
import 'package:online_food_ordering/features/customer/profile/screens/profile_screen.dart';
import 'package:online_food_ordering/features/customer/orders/screens/orders_screen.dart';

/// Production-ready luxury home screen with category filtering and responsive grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: bottomNavIndex,
        children: [
          const _HomeBody(),
          const FavoritesScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomNavIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredFoods = ref.watch(filteredFoodsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 16, tablet: 20, desktop: 24),
                      ),

                      // Header
                      const HomeHeader(),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 20, tablet: 24, desktop: 28),
                      ),

                      // Search bar
                      HomeSearchBar(
                        onChanged: (query) {
                          ref.read(searchQueryProvider.notifier).state = query;
                        },
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 20, tablet: 24, desktop: 28),
                      ),

                      // Promo banner
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ResponsiveHelper.getMaxWidth(context),
                          ),
                          child: const PromoBanner(
                            title: '30% OFF',
                            subtitle: 'Premium Burgers & BBQ',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 24, tablet: 28, desktop: 32),
                      ),

                      // Category selector
                      CategorySelector(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        },
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 20, tablet: 24, desktop: 28),
                      ),

                      // Featured section title
                      SectionTitle(
                        title: 'Featured Dishes',
                        onViewAll: () {},
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 12, tablet: 16, desktop: 20),
                      ),

                      // Responsive food grid
                      ResponsiveFoodGrid(foods: filteredFoods),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveSize(context,
                            mobile: 24, tablet: 28, desktop: 32),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
