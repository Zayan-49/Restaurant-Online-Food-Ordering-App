import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import 'package:online_food_ordering/routes/app_router.dart';
import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/core/config/app_config.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Initial delay for luxury shimmer animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // 2. Check for active Supabase session
    final user = ref.read(currentUserProvider);

    if (user != null) {
      // 3. IF LOGGED IN: Recover the user's role from Supabase profiles
      try {
        final role = await ref.read(userRoleProvider.future);
        
        if (role != null && mounted) {
          final detectedType = role == 'restaurant_admin' 
              ? AppType.restaurant 
              : AppType.customer;
          
          // Sync global app state with recovered role
          ref.read(appConfigProvider.notifier).setConfig(detectedType);
          
          // Direct navigation to their respective Home
          context.go(AppRoutes.home);
        } else {
          // If profile fetch fails, go to login for safety
          context.go(AppRoutes.login);
        }
      } catch (e) {
        // Fallback for network issues or missing profiles
        context.go(AppRoutes.login);
      }
    } else {
      // 4. NOT LOGGED IN: Show onboarding/login
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BaseShimmer(
              child: Image.asset(
                AppAssets.logo,
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 32),
            BaseShimmer(
              baseColor: Theme.of(context).colorScheme.primary,
              highlightColor: Colors.white70,
              child: const Text(
                'LUXURY DINING',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
