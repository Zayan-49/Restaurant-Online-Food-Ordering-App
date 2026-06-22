import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/home/widgets/category_chip.dart';
import 'package:online_food_ordering/core/models/food_model.dart';

/// Horizontal category selector widget.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<CategoryModel> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final height =
        ResponsiveHelper.getResponsiveHeight(context);
    final horizontalPadding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 20, desktop: 24);
    final spacing = ResponsiveHelper.getGridCrossAxisSpacing(context) / 2;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryTitle = category.id == 'all' ? 'All' : category.name;

          return CategoryChip(
            label: categoryTitle,
            isSelected: selectedCategory == categoryTitle,
            onTap: () => onCategorySelected(categoryTitle),
          );
        },
      ),
    );
  }
}


