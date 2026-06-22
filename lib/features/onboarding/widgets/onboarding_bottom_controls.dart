import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class OnboardingBottomControls extends StatelessWidget {
  const OnboardingBottomControls({
    super.key,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
    required this.isDesktop,
  });

  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);
    final buttonWidth = isDesktop ? 200.0 : 160.0;

    return Row(
      children: [
        TextButton(
          onPressed: onSkip,
          child: Text(
            AppStrings.onboardingSkip,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textGrey,
                  fontSize: ResponsiveHelper.getTitleSmallFontSize(context),
                ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(
              isLastPage
                  ? AppStrings.onboardingGetStarted
                  : AppStrings.onboardingNext,
              style: TextStyle(
                fontSize: ResponsiveHelper.getLabelLargeFontSize(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
