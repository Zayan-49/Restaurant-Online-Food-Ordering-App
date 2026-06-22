import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

/// Luxury search bar for home screen.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.onPressed,
  });

  final Function(String)? onChanged;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 20, desktop: 24);
    final height =
        ResponsiveHelper.getResponsiveHeight(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getAdaptiveSize(context,
                        mobile: 12, tablet: 14, desktop: 16)),
                child: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: iconSize,
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search dishes...',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveHelper.getBodyLargeFontSize(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


