import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';
class AppTextTheme {
  AppTextTheme._();
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
      ).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      );
}
