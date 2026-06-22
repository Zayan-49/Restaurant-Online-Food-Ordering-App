import 'package:flutter/material.dart';
import 'screen_breakpoints.dart';
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  @override
  Widget build(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (ScreenBreakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
