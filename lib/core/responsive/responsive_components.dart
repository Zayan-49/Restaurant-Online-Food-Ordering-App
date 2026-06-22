import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Reusable responsive wrapper for screens with SafeArea, scrolling, and max width
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.scrollable = true,
    this.backgroundColor,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool scrollable;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.getMaxWidth(context),
        ),
        child: Padding(
          padding: padding ?? ResponsiveHelper.getSafeContentPadding(context),
          child: child,
        ),
      ),
    );

    if (scrollable) {
      return SingleChildScrollView(
        child: content,
      );
    }

    return content;
  }
}

/// Responsive container with automatic width capping
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.getMaxWidth(context),
        ),
        child: Container(
          color: backgroundColor,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

