import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';

class SupabaseStorageService {
  final _client = SupabaseConfig.client;

  /// Uploads an image for menu items.
  Future<String> uploadFoodImage(String path) async {
    return _uploadImage(path, 'food-images', 'food');
  }

  /// Uploads branding assets (Logo or Deal).
  Future<String> uploadBrandingImage(String path, String type) async {
    return _uploadImage(path, 'branding', type);
  }

  /// Uploads user avatars to their own folder for security.
  Future<String> uploadAvatar({
    required String path,
    required String userId,
  }) async {
    // Path: branding/{userId}/avatar_timestamp.jpg
    return _uploadImage(path, 'branding', '$userId/avatar');
  }

  /// Uploads user avatars for Web.
  Future<String> uploadAvatarWeb({
    required Uint8List bytes,
    required String fileName,
    required String userId,
  }) async {
    return uploadImageWeb(bytes, fileName, 'branding', '$userId/avatar');
  }

  /// Generic upload handler for Mobile.
  Future<String> _uploadImage(String localPath, String bucket, String prefix) async {
    try {
      final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(localPath);

      await _client.storage.from(bucket).upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      return _client.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Generic upload handler for Web.
  Future<String> uploadImageWeb(Uint8List bytes, String fileName, String bucket, String prefix) async {
    try {
      final uniqueName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(' ', '_')}';
      
      await _client.storage.from(bucket).uploadBinary(
            uniqueName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      return _client.storage.from(bucket).getPublicUrl(uniqueName);
    } catch (e) {
      throw Exception('Web upload failed: $e');
    }
  }
}
