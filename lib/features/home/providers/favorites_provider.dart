import 'package:flutter_riverpod/flutter_riverpod.dart';

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
