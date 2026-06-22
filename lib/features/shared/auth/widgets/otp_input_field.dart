import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable OTP input field for 6-digit codes with responsive sizing.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.onCompleted,
  });

  final ValueChanged<String> onChanged;
  final int length;
  final VoidCallback? onCompleted;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else {
      final otp = _controllers.map((c) => c.text).join();
      widget.onChanged(otp);

      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else if (otp.length == widget.length) {
        _focusNodes[index].unfocus();
        widget.onCompleted?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    // Responsive field sizing
    late final double fieldSize;
    late final double fieldSpacing;
    late final double fontSize;

    if (isDesktop) {
      // Desktop: larger boxes, wider spacing
      fieldSize = 52.0;
      fieldSpacing = 12.w;
      fontSize = 18.0;
    } else if (isTablet) {
      // Tablet: medium boxes, balanced spacing
      fieldSize = 48.0.w;
      fieldSpacing = 10.w;
      fontSize = 18.0;
    } else {
      // Mobile: compact boxes, tight spacing
      fieldSize = 44.0.w;
      fieldSpacing = 8.w;
      fontSize = 16.0;
    }

    // Constraint total width to prevent overflow
    final totalWidth = (fieldSize * widget.length) + (fieldSpacing * (widget.length - 1));
    final maxAvailableWidth = screenWidth * 0.9; // 90% of screen with padding

    // If content would overflow, scale down
    final isOverflowing = totalWidth > maxAvailableWidth;
    final scaleFactor = isOverflowing ? maxAvailableWidth / totalWidth : 1.0;
    final adjustedFieldSize = fieldSize * scaleFactor;
    final adjustedFieldSpacing = fieldSpacing * scaleFactor;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.length,
          (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: adjustedFieldSpacing / 2),
            child: SizedBox(
              width: adjustedFieldSize,
              height: adjustedFieldSize,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (value) => _onChanged(value, index),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.all(8.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

