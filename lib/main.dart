import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  // SETTING TO RESTAURANT BY DEFAULT FOR TESTING
  const config = AppConfig(
    appType: AppType.restaurant, // Changed from customer to restaurant
    appName: 'Restaurant Admin - Test',
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

class LuxuryFoodOrderingApp extends ConsumerWidget {
  const LuxuryFoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
