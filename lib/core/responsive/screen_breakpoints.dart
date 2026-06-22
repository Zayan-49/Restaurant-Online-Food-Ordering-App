import 'package:flutter/widgets.dart';

/// Professional responsive breakpoints for luxury app design
class ScreenBreakpoints {
  ScreenBreakpoints._();

  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double largeDesktopMinWidth = 1440;

  // Screen detection
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMaxWidth && width < largeDesktopMinWidth;
  }

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= largeDesktopMinWidth;

  // Get current screen size
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.sizeOf(context);

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;
}
