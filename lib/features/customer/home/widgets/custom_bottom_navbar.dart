import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

/// Custom luxury bottom navigation bar.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Home', Icons.home_rounded),
      ('Favorites', Icons.favorite_rounded),
      ('Orders', Icons.receipt_long_rounded),
      ('Profile', Icons.person_rounded),
    ];

    final iconSize =
        ResponsiveHelper.getAdaptiveSize(context,
            mobile: 24, tablet: 28, desktop: 32);
    final labelFontSize =
        ResponsiveHelper.getAdaptiveSize(context,
            mobile: 10, tablet: 11, desktop: 12);
    final navBarPadding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 4, tablet: 6, desktop: 8);
    final itemPadding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 12, tablet: 14, desktop: 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getAdaptiveSize(context,
                mobile: 8, tablet: 12, desktop: 16),
            vertical: navBarPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              tabs.length,
              (index) {
                final (label, icon) = tabs[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: itemPadding,
                      vertical: ResponsiveHelper.getAdaptiveSize(context,
                          mobile: 8, tablet: 10, desktop: 12),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: iconSize,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getAdaptiveSize(context,
                              mobile: 2, tablet: 4, desktop: 6),
                        ),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontSize: labelFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

