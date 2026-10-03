import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/models/deal_model.dart';
import 'package:online_food_ordering/services/storage/supabase_storage_service.dart';
import 'dart:typed_data';

/// Real-time stream of all deals with caching enabled.
final allDealsProvider = StreamProvider<List<DealModel>>((ref) {
  ref.keepAlive(); // Cache enabled
  return SupabaseConfig.client
      .from('deals')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .asyncMap((data) async {
        final List<DealModel> deals = [];
        for (var map in data) {
          final itemsResponse = await SupabaseConfig.client
              .from('deal_items')
              .select('*, foods(*)')
              .eq('deal_id', map['id']);
          
          final dealMap = Map<String, dynamic>.from(map);
          dealMap['deal_items'] = itemsResponse;
          deals.add(DealModel.fromMap(dealMap));
        }
        return deals;
      });
});

final dealActionsProvider = Provider((ref) => DealActions());

class DealActions {
  final _supabase = SupabaseConfig.client;
  final _storage = SupabaseStorageService();

  Future<void> createBundleDeal({
    required String title,
    required String description,
    required double price,
    required List<String> selectedFoodIds,
    String? localPath,
    Uint8List? webBytes,
    String? webFileName,
  }) async {
    String? imageUrl;

    if (localPath != null) {
      imageUrl = await _storage.uploadBrandingImage(localPath, 'deal');
    } else if (webBytes != null && webFileName != null) {
      imageUrl = await _storage.uploadImageWeb(webBytes, webFileName, 'branding', 'deal');
    }

    if (imageUrl == null) throw Exception('Deal banner image is required');

    final dealResponse = await _supabase.from('deals').insert({
      'title': title,
      'description': description,
      'deal_price': price,
      'image_url': imageUrl,
      'is_active': true,
    }).select().single();

    final dealId = dealResponse['id'] as String;

    final List<Map<String, dynamic>> itemsToInsert = selectedFoodIds.map((foodId) => {
      'deal_id': dealId,
      'food_id': foodId,
      'quantity': 1,
    }).toList();

    await _supabase.from('deal_items').insert(itemsToInsert);
  }

  Future<void> deleteDeal(String id) async {
    await _supabase.from('deals').delete().eq('id', id);
  }

  Future<void> toggleDealStatus(String id, bool status) async {
    await _supabase.from('deals').update({'is_active': status}).eq('id', id);
  }
}
