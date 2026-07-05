import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/app_config.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWith((ref) => AppConfigNotifier()..setConfig(AppType.restaurant)),
      ],
      child: const LuxuryFoodOrderingApp(),
    ),
  );
}
