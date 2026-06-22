import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/app_config.dart';
import 'package:online_food_ordering/main.dart';

void main() {
  const config = AppConfig(
    appType: AppType.customer,
    appName: 'Luxury Customer',
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const LuxuryFoodOrderingApp(),
    ),
  );
}
