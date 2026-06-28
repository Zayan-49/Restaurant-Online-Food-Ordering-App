import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({
    super.key,
    required this.model,
    required this.isActive,
    required this.isDesktop,
    required this.isTablet,
  });

  final OnboardingModel model;
  final bool isActive;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final desiredWidth = isDesktop
        ? 340.0
        : isTablet
            ? 300.0
            : 280.0;
    final desiredHeight = isDesktop
        ? 280.0
        : isTablet
            ? 260.0
            : 240.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 380),
      opacity: isActive ? 1 : 0.86,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 380),
        scale: isActive ? 1 : 0.97,
        curve: Curves.easeOutCubic,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: desiredWidth,
              maxHeight: desiredHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  model.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
