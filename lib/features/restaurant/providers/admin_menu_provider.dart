import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/services/storage/supabase_storage_service.dart';
import 'dart:typed_data';

/// Real-time provider for the menu items in the database.
final adminMenuProvider = StreamProvider<List<FoodModel>>((ref) {
  return SupabaseConfig.client
      .from('foods')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data.map((map) => FoodModel.fromMap(map)).toList());
});

/// Provider for admin menu actions.
final adminMenuActionsProvider = Provider((ref) => AdminMenuActions());

class AdminMenuActions {
  final _supabase = SupabaseConfig.client;
  final _storage = SupabaseStorageService();

  Future<void> addItem({
    required String title,
    required double price,
    required String category,
    required String description,
    String? localPath,
    Uint8List? webBytes,
    String? webFileName,
  }) async {
    String? imageUrl;

    // 1. Upload image if provided
    if (localPath != null) {
      imageUrl = await _storage.uploadFoodImage(localPath);
    } else if (webBytes != null && webFileName != null) {
      imageUrl = await _storage.uploadImageWeb(webBytes, webFileName, 'food-images', 'food');
    }

    // 2. Insert into DB
    await _supabase.from('foods').insert({
      'title': title,
      'price': price,
      'category': category,
      'description': description,
      'image_url': imageUrl ?? 'https://via.placeholder.com/150',
    });
  }

  Future<void> updateItem(String id, {
    String? title,
    double? price,
    String? category,
    String? description,
    String? localPath,
    Uint8List? webBytes,
    String? webFileName,
  }) async {
    Map<String, dynamic> updates = {};
    if (title != null) updates['title'] = title;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;

    // Handle new image upload
    if (localPath != null) {
      updates['image_url'] = await _storage.uploadFoodImage(localPath);
    } else if (webBytes != null && webFileName != null) {
      updates['image_url'] = await _storage.uploadImageWeb(webBytes, webFileName, 'food-images', 'food');
    }

    if (updates.isNotEmpty) {
      await _supabase.from('foods').update(updates).eq('id', id);
    }
  }

  Future<void> deleteItem(String id) async {
    await _supabase.from('foods').delete().eq('id', id);
  }
}
