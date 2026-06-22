import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';

/// Provider for the favorites state (Set of food IDs).
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleFavorite(String foodId) {
    if (state.contains(foodId)) {
      state = {...state}..remove(foodId);
    } else {
      state = {...state, foodId};
    }
  }

  bool isFavorite(String foodId) {
    return state.contains(foodId);
  }
}

/// Derived provider to get actual FoodModel objects for favorites.
final favoriteFoodsProvider = Provider<List<FoodModel>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final allFoods = ref.watch(allFoodsProvider);
  
  return allFoods.where((food) => favoriteIds.contains(food.id)).toList();
});
