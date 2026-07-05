import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase & Dotenv
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: LuxuryFoodOrderingApp(),
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
