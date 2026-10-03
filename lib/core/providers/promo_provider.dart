import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/promo_model.dart';
import 'package:online_food_ordering/services/storage/supabase_storage_service.dart';
import 'dart:typed_data';

/// Stream of all advertisements from Supabase with caching.
final allPromosProvider = StreamProvider<List<PromoModel>>((ref) {
  ref.keepAlive(); // Cache enabled
  return SupabaseConfig.client
      .from('promotions')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data.map((map) => PromoModel.fromMap(map)).toList());
});

/// Selects the first active promo to show on the Customer Home.
final activePromoProvider = Provider<PromoModel?>((ref) {
  final promos = ref.watch(allPromosProvider).value ?? [];
  final activeList = promos.where((p) => p.isActive).toList();
  return activeList.isNotEmpty ? activeList.first : null;
});

/// Provider for admin advertisement actions.
final promoActionsProvider = Provider((ref) => PromoActions());

class PromoActions {
  final _supabase = SupabaseConfig.client;
  final _storage = SupabaseStorageService();

  Future<void> addPromo({
    required String title,
    required String subtitle,
    String? localPath,
    Uint8List? webBytes,
    String? webFileName,
  }) async {
    String? imageUrl;

    if (localPath != null) {
      imageUrl = await _storage.uploadBrandingImage(localPath, 'promo');
    } else if (webBytes != null && webFileName != null) {
      imageUrl = await _storage.uploadImageWeb(webBytes, webFileName, 'branding', 'promo');
    }

    if (imageUrl == null) throw Exception('Banner image is required');

    await _supabase.from('promotions').insert({
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'is_active': true,
    });
  }

  Future<void> deletePromo(String id) async {
    await _supabase.from('promotions').delete().eq('id', id);
  }

  Future<void> togglePromoStatus(String id, bool status) async {
    await _supabase.from('promotions').update({'is_active': status}).eq('id', id);
  }
}
