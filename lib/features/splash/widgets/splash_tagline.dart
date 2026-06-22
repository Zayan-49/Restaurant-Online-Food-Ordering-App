import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
/// Premium, minimal brand message beneath the logo.
class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key, this.isDesktop = false});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = (isDesktop ? textTheme.titleMedium : textTheme.headlineSmall)
        ?.copyWith(
      color: AppColors.textDark,
      letterSpacing: 0.15,
      height: 1.08,
    );

    final subtitleStyle = (isDesktop ? textTheme.bodySmall : textTheme.bodyMedium)
        ?.copyWith(
      color: AppColors.textGrey,
      height: 1.35,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        SizedBox(height: isDesktop ? 6.h : 10.h),
        Text(
          AppStrings.splashTagline,
          textAlign: TextAlign.center,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
