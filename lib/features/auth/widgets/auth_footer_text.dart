import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

/// Footer text for auth screens (e.g., navigation between screens).
class AuthFooterText extends StatelessWidget {
  const AuthFooterText({
    super.key,
    required this.text,
    required this.actionText,
    required this.onActionTap,
  });

  final String text;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getBodyMediumFontSize(context);

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
              ),
        ),
        TextButton(
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          ),
          child: Text(
            actionText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
