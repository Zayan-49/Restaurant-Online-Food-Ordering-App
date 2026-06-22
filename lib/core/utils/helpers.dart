import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
class Helpers {
  Helpers._();
  static void unfocusKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.textDark,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  static String formatPrice(num value, {String currency = '24'}) {
    return '$currency${value.toStringAsFixed(2)}';
  }
}
