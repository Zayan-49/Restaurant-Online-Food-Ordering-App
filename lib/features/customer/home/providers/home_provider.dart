import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/features/restaurant/providers/deal_provider.dart';

/// Index for the bottom navigation bar.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Category filter state.
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Search query state.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// AI interpreted keywords for search.
final aiSearchKeywordsProvider = StateProvider<String?>((ref) => null);

/// Loading state for AI search.
final isAISearchLoadingProvider = StateProvider<bool>((ref) => false);

/// Real-time stream of all food items from Supabase.
final allFoodsStreamProvider = StreamProvider<List<FoodModel>>((ref) {
  ref.keepAlive(); 
  return SupabaseConfig.client
      .from('foods')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data.map((map) => FoodModel.fromMap(map)).toList());
});

/// A PERSISTENT Notifier that remembers data and never shows loading again after the first success.
final persistentFoodsProvider = StateNotifierProvider<PersistentFoodNotifier, List<FoodModel>>((ref) {
  final stream = ref.watch(allFoodsStreamProvider);
  return PersistentFoodNotifier(stream.value ?? []);
});

class PersistentFoodNotifier extends StateNotifier<List<FoodModel>> {
  PersistentFoodNotifier(super.state);

  void updateData(List<FoodModel> newData) {
    if (newData.isNotEmpty) {
      state = newData;
    }
  }
}

/// Filtered food items based on category, search query, and AI intent.
final filteredFoodsProvider = Provider<List<FoodModel>>((ref) {
  final allFoods = ref.watch(persistentFoodsProvider);
  final dealsAsync = ref.watch(allDealsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final rawQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final aiKeywords = ref.watch(aiSearchKeywordsProvider);

  // Sync the persistent state with stream data in the background
  ref.listen(allFoodsStreamProvider, (prev, next) {
    if (next.hasValue) {
      ref.read(persistentFoodsProvider.notifier).updateData(next.value!);
    }
  });

  final activeDeals = (dealsAsync.value ?? []).where((d) => d.isActive).toList();

  final dealAsFoods = activeDeals.map((deal) => FoodModel(
    id: 'deal_${deal.id}',
    title: deal.title,
    description: deal.description,
    category: 'Deals',
    price: deal.dealPrice,
    imageUrl: deal.imageUrl,
    rating: 5.0,
    reviewCount: 0,
  )).toList();

  List<FoodModel> sourceList;
  if (selectedCategory == 'All') {
    sourceList = [...dealAsFoods, ...allFoods];
  } else if (selectedCategory == 'Deals') {
    sourceList = dealAsFoods;
  } else {
    sourceList = allFoods.where((food) => food.category == selectedCategory).toList();
  }

  if (rawQuery.isEmpty) return sourceList;

  final queryWords = rawQuery.split(' ').where((w) => w.length > 2).toList();

  return sourceList.where((food) {
    final title = food.title.toLowerCase();
    final desc = food.description.toLowerCase();
    final cat = food.category.toLowerCase();

    if (title.contains(rawQuery) || desc.contains(rawQuery)) return true;
    if (queryWords.any((word) => title.contains(word) || desc.contains(word))) return true;

    if (aiKeywords != null) {
      final aiWords = aiKeywords.split(',').map((k) => k.trim().toLowerCase());
      return aiWords.any((k) => title.contains(k) || desc.contains(k) || cat.contains(k));
    }
    return false;
  }).toList();
});
