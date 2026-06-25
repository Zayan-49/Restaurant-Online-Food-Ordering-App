import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';

/// Provider for the admin menu state.
final adminMenuProvider = NotifierProvider<AdminMenuNotifier, List<FoodModel>>(AdminMenuNotifier.new);

class AdminMenuNotifier extends Notifier<List<FoodModel>> {
  @override
  List<FoodModel> build() {
    // Populate with existing food data from home_provider
    return ref.watch(allFoodsProvider);
  }

  void toggleAvailability(String id) {
    // For now, FoodModel doesn't have an isAvailable field. 
    // In a real app, we would add it. Let's simulate it by updating the state.
    // Since FoodModel is immutable, we'd normally use copyWith if it had the field.
  }

  void updatePrice(String id, double newPrice) {
    state = [
      for (final food in state)
        if (food.id == id)
          FoodModel(
            id: food.id,
            title: food.title,
            description: food.description,
            category: food.category,
            price: newPrice,
            imageUrl: food.imageUrl,
            rating: food.rating,
            reviewCount: food.reviewCount,
          )
        else
          food,
    ];
  }

  void deleteItem(String id) {
    state = state.where((food) => food.id != id).toList();
  }

  void addItem(FoodModel newItem) {
    state = [...state, newItem];
  }
}
