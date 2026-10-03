import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';
import 'package:online_food_ordering/features/restaurant/providers/deal_provider.dart';

/// Provider for the favorites state (Set of item IDs from Supabase).
final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  final _supabase = SupabaseConfig.client;

  @override
  Future<Set<String>> build() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    try {
      final response = await _supabase
          .from('favorites')
          .select('food_id')
          .eq('user_id', user.id);
      
      return response.map((item) => item['food_id'] as String).toSet();
    } catch (e) {
      debugPrint("FAVORITES FETCH ERROR: $e");
      return {};
    }
  }

  Future<void> toggleFavorite(String itemId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final currentSet = state.value ?? {};
    final isFav = currentSet.contains(itemId);

    final newSet = {...currentSet};
    if (isFav) newSet.remove(itemId); else newSet.add(itemId);
    state = AsyncData(newSet);

    try {
      if (isFav) {
        await _supabase.from('favorites').delete().eq('user_id', user.id).eq('food_id', itemId);
      } else {
        await _supabase.from('favorites').insert({'user_id': user.id, 'food_id': itemId});
      }
    } catch (e) {
      state = AsyncData(currentSet);
      rethrow;
    }
  }
}

/// Derived provider to get actual FoodModel objects (including Deals) for the Favorites Screen.
final favoriteFoodsProvider = Provider<List<FoodModel>>((ref) {
  final favoriteIdsAsync = ref.watch(favoritesProvider);
  
  // Use the PERSISTENT providers for stability
  final allFoods = ref.watch(persistentFoodsProvider);
  final dealsAsync = ref.watch(allDealsProvider);
  
  // SAFE ACCESS
  final allDeals = (dealsAsync.asData?.value ?? []).where((d) => d.isActive).toList();

  final dealAsFoods = allDeals.map((deal) => FoodModel(
    id: 'deal_${deal.id}',
    title: deal.title,
    description: deal.description,
    category: 'Deals',
    price: deal.dealPrice,
    imageUrl: deal.imageUrl,
    rating: 5.0,
    reviewCount: 0,
  )).toList();

  final combinedSource = [...dealAsFoods, ...allFoods];

  return favoriteIdsAsync.maybeWhen(
    data: (ids) => combinedSource.where((item) => ids.contains(item.id)).toList(),
    orElse: () => [],
  );
});
