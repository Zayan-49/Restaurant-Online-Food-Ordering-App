import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppType {
  customer,
  restaurant,
}

class AppConfig {
  final AppType appType;
  final String appName;

  const AppConfig({
    required this.appType,
    required this.appName,
  });
}

/// Global provider for app configuration (set at startup)
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in ProviderScope');
});
