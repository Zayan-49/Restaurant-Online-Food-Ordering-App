import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/models/user_model.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/services/storage/supabase_storage_service.dart';
import 'dart:typed_data';

/// Real-time provider for the current user's profile with caching.
final userProvider = StreamProvider<UserModel?>((ref) {
  ref.keepAlive(); // Cache enabled
  final authUser = ref.watch(currentUserProvider);
  if (authUser == null) return Stream.value(null);

  return SupabaseConfig.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', authUser.id)
      .map((data) {
        if (data.isEmpty) return null;
        return UserModel.fromMap(data.first, authUser.email ?? '');
      });
});

final userActionsProvider = Provider((ref) => UserActions());

class UserActions {
  final _supabase = SupabaseConfig.client;
  final _storage = SupabaseStorageService();

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? localPath,
    Uint8List? webBytes,
    String? webFileName,
  }) async {
    Map<String, dynamic> updates = {};
    if (name != null && name.isNotEmpty) updates['full_name'] = name;

    try {
      if (localPath != null) {
        updates['avatar_url'] = await _storage.uploadAvatar(path: localPath, userId: userId);
      } else if (webBytes != null && webFileName != null) {
        updates['avatar_url'] = await _storage.uploadAvatarWeb(bytes: webBytes, fileName: webFileName, userId: userId);
      }

      if (updates.isNotEmpty) {
        await _supabase.from('profiles').update(updates).eq('id', userId);
      }
    } catch (e) {
      rethrow;
    }
  }
}
