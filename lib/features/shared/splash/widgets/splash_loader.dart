import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
import 'package:online_food_ordering/core/constants/app_strings.dart';
/// Minimal loading treatment for the splash screen.
class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22.r,
          height: 22.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          AppStrings.splashLoading,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textGrey,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
