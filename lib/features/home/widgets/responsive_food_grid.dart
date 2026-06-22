import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/home/models/food_model.dart';
import 'package:online_food_ordering/features/home/widgets/food_card.dart';

/// Responsive food grid that adapts to screen size using MaxCrossAxisExtent.
class ResponsiveFoodGrid extends StatelessWidget {
  const ResponsiveFoodGrid({
    super.key,
    required this.foods,
  });

  final List<FoodModel> foods;

  @override
  Widget build(BuildContext context) {
    final crossAxisSpacing = ResponsiveHelper.getGridCrossAxisSpacing(context);
    final mainAxisSpacing = ResponsiveHelper.getGridMainAxisSpacing(context);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 8, tablet: 12, desktop: 16);

    // Dynamic extent and aspect ratio based on screen type
    double maxExtent = 180;
    double aspectRatio = 0.72; // Default for mobile
    
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) {
      maxExtent = 280;
      aspectRatio = 0.85; // Wider for large desktop
    } else if (width > 800) {
      maxExtent = 240;
      aspectRatio = 0.8;
    } else if (width > 600) {
      maxExtent = 220;
      aspectRatio = 0.78;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: ResponsiveHelper.getAdaptiveSize(context,
            mobile: 12, tablet: 16, desktop: 20),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxExtent,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          return FoodCard(food: foods[index]);
        },
      ),
    );
  }
}
