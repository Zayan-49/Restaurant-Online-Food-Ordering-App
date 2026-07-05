class CategoryModel {
  final String id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });
}

class FoodModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  const FoodModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl, // Consistent with DB field name
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled Dish',
      description: map['description']?.toString() ?? 'No description available.',
      category: map['category']?.toString() ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url']?.toString() ?? map['imageUrl']?.toString() ?? 'https://via.placeholder.com/150',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? (map['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
