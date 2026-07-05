import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';

/// Provider for the favorites state (Set of food IDs from Supabase).
final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  final _supabase = SupabaseConfig.client;

  @override
  Future<Set<String>> build() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    // Fetch initial favorites from DB
    final response = await _supabase
        .from('favorites')
        .select('food_id')
        .eq('user_id', user.id);
    
    return response.map((item) => item['food_id'] as String).toSet();
  }

  Future<void> toggleFavorite(String foodId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final currentSet = state.value ?? {};
    final isFav = currentSet.contains(foodId);

    // Optimistic UI Update for luxury feel
    final newSet = {...currentSet};
    if (isFav) newSet.remove(foodId); else newSet.add(foodId);
    state = AsyncData(newSet);

    try {
      if (isFav) {
        await _supabase.from('favorites').delete().eq('user_id', user.id).eq('food_id', foodId);
      } else {
        await _supabase.from('favorites').insert({'user_id': user.id, 'food_id': foodId});
      }
    } catch (e) {
      // Revert on error
      state = AsyncData(currentSet);
      rethrow;
    }
  }

  bool isFavorite(String foodId) {
    return state.value?.contains(foodId) ?? false;
  }
}

/// Derived provider to get actual FoodModel objects for the Favorites Screen.
final favoriteFoodsProvider = Provider<List<FoodModel>>((ref) {
  final favoriteIdsAsync = ref.watch(favoritesProvider);
  final allFoodsAsync = ref.watch(allFoodsProvider);
  
  return allFoodsAsync.maybeWhen(
    data: (allFoods) {
      return favoriteIdsAsync.maybeWhen(
        data: (ids) => allFoods.where((food) => ids.contains(food.id)).toList(),
        orElse: () => [],
      );
    },
    orElse: () => [],
  );
});
