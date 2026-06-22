import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getAdaptiveSize(context,
            mobile: 20, tablet: 24, desktop: 28),
      ),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontSize: ResponsiveHelper.getTitleLargeFontSize(context),
            ),
          ),
          SizedBox(
            height: ResponsiveHelper.getAdaptiveSize(context,
                mobile: 4, tablet: 6, desktop: 8),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
            ),
          ),
        ],
      ),
    );
  }
}
