import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
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
    final textTheme = Theme.of(context).textTheme;
    final titleSize = ResponsiveHelper.getHeadlineLargeFontSize(context);
    final descriptionSize = ResponsiveHelper.getBodyMediumFontSize(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 360),
      opacity: isActive ? 1 : 0.88,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 360),
        offset: isActive ? Offset.zero : const Offset(0, 0.02),
        curve: Curves.easeOutCubic,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 450 : 380,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: titleSize,
                  color: AppColors.textDark,
                  height: 1.15,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                model.description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: descriptionSize,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
