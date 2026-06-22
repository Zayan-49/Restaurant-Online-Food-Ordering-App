import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_food_ordering/core/constants/app_assets.dart';
import 'package:online_food_ordering/core/constants/app_colors.dart';
/// Premium logo treatment for the splash screen.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, this.size = 124});
  final double size;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32.r);
    return Container(
      width: size.w,
      height: size.w,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.local_dining,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
