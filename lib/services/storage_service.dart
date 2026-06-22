class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  final Map<String, Object?> _cache = <String, Object?>{};
  Future<void> writeString(String key, String value) async {
    _cache[key] = value;
  }
  Future<String?> readString(String key) async {
    final value = _cache[key];
    return value is String ? value : null;
  }
  Future<void> remove(String key) async {
    _cache.remove(key);
  }
}
