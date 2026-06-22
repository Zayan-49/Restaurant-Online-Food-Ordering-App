import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/features/home/models/food_model.dart';

/// Fake local food data - in production this would come from backend
final allFoodsProvider = Provider<List<FoodModel>>((ref) {
  return [
    // Burgers
    const FoodModel(
      id: '1',
      title: 'Premium Beef Burger',
      description: 'Juicy certified Angus beef burger with aged cheddar, caramelized onions, and truffle aioli on a toasted brioche bun.',
      category: 'Burgers',
      price: 18.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.8,
      reviewCount: 342,
    ),
    const FoodModel(
      id: '2',
      title: 'Classic Cheeseburger',
      description: 'Traditional burger with melted American cheese, crispy bacon, fresh lettuce, tomato, and special sauce.',
      category: 'Burgers',
      price: 14.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.6,
      reviewCount: 521,
    ),
    const FoodModel(
      id: '3',
      title: 'Spicy Pepper Burger',
      description: 'Bold and fiery burger with ghost pepper mayo, red pepper jam, and jalapeños.',
      category: 'Burgers',
      price: 16.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.5,
      reviewCount: 289,
    ),

    // Pizza
    const FoodModel(
      id: '4',
      title: 'Margherita Pizza',
      description: 'Classic Italian pizza with fresh mozzarella, basil, and San Marzano tomato sauce on wood-fired crust.',
      category: 'Pizza',
      price: 16.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.9,
      reviewCount: 615,
    ),
    const FoodModel(
      id: '5',
      title: 'Seafood Deluxe Pizza',
      description: 'Premium pizza topped with shrimp, calamari, mussels, and garlic butter sauce.',
      category: 'Pizza',
      price: 24.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.7,
      reviewCount: 398,
    ),
    const FoodModel(
      id: '6',
      title: 'BBQ Chicken Pizza',
      description: 'Smoky BBQ sauce base with grilled chicken, red onions, cilantro, and crispy bacon.',
      category: 'Pizza',
      price: 19.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.7,
      reviewCount: 423,
    ),

    // BBQ
    const FoodModel(
      id: '7',
      title: 'Smoked Brisket',
      description: 'Slow-smoked premium brisket with house-made BBQ sauce and coleslaw.',
      category: 'BBQ',
      price: 25.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.9,
      reviewCount: 287,
    ),
    const FoodModel(
      id: '8',
      title: 'BBQ Ribs combo',
      description: 'Fall-off-the-bone ribs with three house-made sauce options and sides.',
      category: 'BBQ',
      price: 28.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.8,
      reviewCount: 412,
    ),
    const FoodModel(
      id: '9',
      title: 'Pulled Pork Sandwich',
      description: 'Tender pulled pork on brioche with pickles and smoky sauce.',
      category: 'BBQ',
      price: 15.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.6,
      reviewCount: 356,
    ),

    // Desserts
    const FoodModel(
      id: '10',
      title: 'Chocolate Lava Cake',
      description: 'Warm decadent chocolate cake with molten center, served with vanilla ice cream.',
      category: 'Desserts',
      price: 9.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.9,
      reviewCount: 789,
    ),
    const FoodModel(
      id: '11',
      title: 'Cheesecake Deluxe',
      description: 'New York style cheesecake with fresh berry compote and whipped cream.',
      category: 'Desserts',
      price: 8.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.7,
      reviewCount: 512,
    ),
    const FoodModel(
      id: '12',
      title: 'Tiramisu',
      description: 'Traditional Italian tiramisu with mascarpone, espresso, and cocoa powder.',
      category: 'Desserts',
      price: 7.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.8,
      reviewCount: 634,
    ),

    // Drinks
    const FoodModel(
      id: '13',
      title: 'Craft Iced Tea',
      description: 'Refreshing blend of premium teas with fresh lemon and mint.',
      category: 'Drinks',
      price: 4.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.5,
      reviewCount: 245,
    ),
    const FoodModel(
      id: '14',
      title: 'Espresso Martini',
      description: 'Smooth martini with fresh espresso, vodka, and coffee liqueur.',
      category: 'Drinks',
      price: 12.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.7,
      reviewCount: 398,
    ),
    const FoodModel(
      id: '15',
      title: 'Tropical Smoothie',
      description: 'Blend of mango, pineapple, coconut milk, and Greek yogurt.',
      category: 'Drinks',
      price: 6.99,
      imageUrl: 'assets/images/Burger.jpg',
      rating: 4.6,
      reviewCount: 321,
    ),
  ];
});

/// Selected category for filtering
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// All available categories
final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return [
    const CategoryModel(id: 'all', name: 'All'),
    const CategoryModel(id: 'burgers', name: 'Burgers'),
    const CategoryModel(id: 'pizza', name: 'Pizza'),
    const CategoryModel(id: 'bbq', name: 'BBQ'),
    const CategoryModel(id: 'desserts', name: 'Desserts'),
    const CategoryModel(id: 'drinks', name: 'Drinks'),
  ];
});

/// Filtered food list based on selected category
final filteredFoodsProvider = Provider<List<FoodModel>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final allFoods = ref.watch(allFoodsProvider);

  if (selectedCategory == 'All') {
    return allFoods;
  }

  return allFoods.where((food) => food.category == selectedCategory).toList();
});

/// Bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

