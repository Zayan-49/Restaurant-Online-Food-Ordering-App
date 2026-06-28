import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';

/// Fully functional provider for admin menu operations.
final adminMenuProvider = NotifierProvider<AdminMenuNotifier, List<FoodModel>>(AdminMenuNotifier.new);

class AdminMenuNotifier extends Notifier<List<FoodModel>> {
  @override
  List<FoodModel> build() {
    return ref.watch(allFoodsProvider);
  }

  void addItem({
    required String title, 
    required double price, 
    required String category, 
    required String description,
    String? imagePath,
  }) {
    final newItem = FoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      price: price,
      category: category,
      description: description,
      imageUrl: imagePath ?? 'assets/images/Burger.jpg',
      rating: 5.0,
      reviewCount: 0,
    );
    state = [...state, newItem];
  }

  void updateItem(String id, {
    String? title, 
    double? price, 
    String? category,
    String? imagePath,
  }) {
    state = [
      for (final food in state)
        if (food.id == id)
          FoodModel(
            id: food.id,
            title: title ?? food.title,
            description: food.description,
            category: category ?? food.category,
            price: price ?? food.price,
            imageUrl: imagePath ?? food.imageUrl,
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
}
