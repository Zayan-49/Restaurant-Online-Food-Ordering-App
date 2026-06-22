import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Password strength indicator with visual feedback.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  /// Calculate password strength: 0 = weak, 1 = medium, 2 = strong
  int _calculateStrength() {
    if (password.isEmpty) return -1; // No password

    int strength = 0;

    // Length requirement
    if (password.length >= 8) strength++;

    // Character variety
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int variety = 0;
    if (hasUppercase) variety++;
    if (hasLowercase) variety++;
    if (hasNumbers) variety++;
    if (hasSpecial) variety++;

    if (variety >= 3) strength++;

    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Weak password';
      case 1:
        return 'Medium password';
      case 2:
        return 'Strong password';
      default:
        return '';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    if (strength == -1) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final color = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 6.w : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: index <= strength ? color : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // Strength text
        Text(
          _getStrengthText(strength),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: isDesktop ? 12.0 : 11.sp,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

