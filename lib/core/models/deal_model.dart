import 'food_model.dart';

class DealItemModel {
  final String id;
  final String dealId;
  final String foodId;
  final int quantity;
  final FoodModel? food; // Optional: Joined data from foods table

  const DealItemModel({
    required this.id,
    required this.dealId,
    required this.foodId,
    required this.quantity,
    this.food,
  });

  factory DealItemModel.fromMap(Map<String, dynamic> map) {
    return DealItemModel(
      id: map['id']?.toString() ?? '',
      dealId: map['deal_id']?.toString() ?? '',
      foodId: map['food_id']?.toString() ?? '',
      quantity: map['quantity'] as int? ?? 1,
      food: map['foods'] != null ? FoodModel.fromMap(map['foods']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deal_id': dealId,
      'food_id': foodId,
      'quantity': quantity,
    };
  }
}

class DealModel {
  final String id;
  final String title;
  final String description;
  final double dealPrice;
  final String imageUrl;
  final List<DealItemModel> items;
  final bool isActive;
  final DateTime? endDate;

  const DealModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dealPrice,
    required this.imageUrl,
    required this.items,
    required this.isActive,
    this.endDate,
  });

  factory DealModel.fromMap(Map<String, dynamic> map) {
    return DealModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Special Deal',
      description: map['description'] ?? '',
      dealPrice: (map['deal_price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? '',
      isActive: map['is_active'] ?? true,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      items: (map['deal_items'] as List<dynamic>?)
              ?.map((x) => DealItemModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
