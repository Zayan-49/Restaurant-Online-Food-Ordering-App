import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import '../models/onboarding_model.dart';
final onboardingIndexProvider = StateNotifierProvider<OnboardingIndexNotifier, int>(
  (ref) => OnboardingIndexNotifier(),
);
final onboardingPageControllerProvider = Provider<PageController>((ref) {
  final controller = PageController();
  ref.onDispose(controller.dispose);
  return controller;
});
final onboardingPagesProvider = Provider<List<OnboardingModel>>((ref) {
  return const [
    OnboardingModel(
      title: 'Fresh & Premium Food',
      description:
          'Discover chef-crafted meals prepared with premium ingredients and delivered with a luxury touch.',
      image: AppAssets.onboardingIllustration,
    ),
    OnboardingModel(
      title: 'Fast Delivery',
      description:
          'Enjoy quick, reliable service with a refined experience from kitchen to doorstep.',
      image: AppAssets.onboardingIllustration,
    ),
    OnboardingModel(
      title: 'Easy Ordering System',
      description:
          'Browse, customize, and place your order in just a few taps with a seamless ordering flow.',
      image: AppAssets.onboardingIllustration,
    ),
  ];
});
class OnboardingIndexNotifier extends StateNotifier<int> {
  OnboardingIndexNotifier() : super(0);
  void setPage(int index) => state = index;
  void next(int totalPages) {
    if (state < totalPages - 1) {
      state += 1;
    }
  }
  void reset() => state = 0;
}
