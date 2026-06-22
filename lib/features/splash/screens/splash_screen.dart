import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import 'package:online_food_ordering/routes/app_router.dart';
import 'package:online_food_ordering/shared/widgets/shimmer_loaders.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
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
            // Logo Shimmer
            BaseShimmer(
              child: Image.asset(
                AppAssets.logo,
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 32),
            // Premium text shimmer - primary color with better contrast
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
