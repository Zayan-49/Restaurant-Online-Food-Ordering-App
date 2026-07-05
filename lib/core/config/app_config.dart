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

class AppConfigNotifier extends StateNotifier<AppConfig> {
  AppConfigNotifier() : super(const AppConfig(
    appType: AppType.customer, 
    appName: 'Luxury Food Ordering'
  ));

  void setConfig(AppType type) {
    state = AppConfig(
      appType: type,
      appName: type == AppType.restaurant ? 'Elite Admin' : 'Luxury Food Ordering',
    );
  }
}

/// Global provider for app configuration that can be updated at runtime
final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfig>((ref) {
  return AppConfigNotifier();
});
