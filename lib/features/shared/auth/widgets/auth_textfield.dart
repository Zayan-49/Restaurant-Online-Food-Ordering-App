import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

/// Reusable text field used across authentication screens.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getBodyLargeFontSize(context);

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
