import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';

/// Index for the bottom navigation bar.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Category filter state.
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Real-time stream of all food items from Supabase.
final allFoodsProvider = StreamProvider<List<FoodModel>>((ref) {
  return SupabaseConfig.client
      .from('foods')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data.map((map) => FoodModel.fromMap(map)).toList());
});

/// Filtered food items based on the selected category.
final filteredFoodsProvider = Provider<List<FoodModel>>((ref) {
  final foodsAsync = ref.watch(allFoodsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return foodsAsync.maybeWhen(
    data: (foods) {
      if (selectedCategory == 'All') return foods;
      return foods.where((food) => food.category == selectedCategory).toList();
    },
    orElse: () => [],
  );
});
