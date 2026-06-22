import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isExpanded = true,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSizes.spacingXs),
          ],
          Text(text),
        ],
      ),
    );
    if (!isExpanded) {
      return button;
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
