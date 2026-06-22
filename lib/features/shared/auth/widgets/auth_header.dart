import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import 'package:online_food_ordering/core/constants/app_strings.dart';

/// Header showing logo and app name used on auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize = ResponsiveHelper.getAdaptiveSize(context, mobile: 80, desktop: 70);
    final titleFontSize = ResponsiveHelper.getTitleLargeFontSize(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // logo
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            AppAssets.logo,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
