import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import 'package:online_food_ordering/core/constants/app_strings.dart';

/// Header showing logo and optional custom title/subtitle for auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;

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
          title ?? AppStrings.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
