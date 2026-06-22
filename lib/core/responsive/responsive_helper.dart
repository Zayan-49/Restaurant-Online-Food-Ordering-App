import 'package:flutter/widgets.dart';
import 'screen_breakpoints.dart';

/// Professional responsive helper for typography, spacing, and sizing
class ResponsiveHelper {
  ResponsiveHelper._();

  // ============== RESPONSIVE TYPOGRAPHY ==============

  /// Get adaptive font size that stays consistent on desktop
  static double getAdaptivefontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (ScreenBreakpoints.isLargeDesktop(context)) {
      return desktopSize ?? (mobileSize + 4);
    } else if (ScreenBreakpoints.isDesktop(context)) {
      return desktopSize ?? (mobileSize + 2);
    } else if (ScreenBreakpoints.isTablet(context)) {
      return tabletSize ?? (mobileSize + 1);
    }

    return mobileSize;
  }

  // Common text sizes - Refined for Desktop to avoid "everything is big"
  static double getDisplayLargeFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 32, desktopSize: 36);

  static double getHeadlineLargeFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 24, desktopSize: 28);

  static double getHeadlineMediumFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 20, desktopSize: 24);

  static double getTitleLargeFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 18, desktopSize: 20);

  static double getTitleMediumFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 16, desktopSize: 18);

  static double getTitleSmallFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 14, desktopSize: 15);

  static double getBodyLargeFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 14, desktopSize: 15);

  static double getBodyMediumFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 12, desktopSize: 14);

  static double getBodySmallFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 11, desktopSize: 12);

  static double getLabelLargeFontSize(BuildContext context) =>
      getAdaptivefontSize(context, mobileSize: 12, desktopSize: 13);

  // ============== RESPONSIVE SPACING ==============

  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    required double mobileValue,
    double? tabletValue,
    double? desktopValue,
  }) {
    final value = getAdaptiveSize(context,
        mobile: mobileValue,
        tablet: tabletValue,
        desktop: desktopValue);
    return EdgeInsets.all(value);
  }

  static EdgeInsets getHorizontalPadding(
    BuildContext context, {
    required double mobileValue,
    double? tabletValue,
    double? desktopValue,
  }) {
    final value = getAdaptiveSize(context,
        mobile: mobileValue,
        tablet: tabletValue,
        desktop: desktopValue);
    return EdgeInsets.symmetric(horizontal: value);
  }

  static EdgeInsets getVerticalPadding(
    BuildContext context, {
    required double mobileValue,
    double? tabletValue,
    double? desktopValue,
  }) {
    final value = getAdaptiveSize(context,
        mobile: mobileValue,
        tablet: tabletValue,
        desktop: desktopValue);
    return EdgeInsets.symmetric(vertical: value);
  }

  // ============== RESPONSIVE SIZING ==============

  static double getAdaptiveSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (ScreenBreakpoints.isLargeDesktop(context)) {
      return desktop ?? (mobile + 6);
    } else if (ScreenBreakpoints.isDesktop(context)) {
      return desktop ?? (mobile + 4);
    } else if (ScreenBreakpoints.isTablet(context)) {
      return tablet ?? (mobile + 2);
    }
    return mobile;
  }

  static double getResponsiveHeight(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 48; // Smaller for desktop than previously defined
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 52;
    }
    return 48;
  }

  static double getResponsiveIconSize(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 24;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 24;
    }
    return 20;
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 48;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 52;
    }
    return 48;
  }

  static double getResponsiveBorderRadius(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 12;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 14;
    }
    return 12;
  }

  // ============== MAX WIDTH CONSTRAINTS ==============

  static double getMaxWidth(BuildContext context, {double fallback = 1200}) {
    final screenWidth = ScreenBreakpoints.getScreenWidth(context);

    if (ScreenBreakpoints.isMobile(context)) {
      return screenWidth - 32;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 800;
    } else if (ScreenBreakpoints.isDesktop(context)) {
      return 1100;
    }
    return fallback;
  }

  static double getAuthCardMaxWidth(BuildContext context) {
    if (ScreenBreakpoints.isMobile(context)) {
      final width = ScreenBreakpoints.getScreenWidth(context);
      return width - 32;
    }
    return 450;
  }

  // ============== GRID SIZING ==============

  static double getGridItemAspectRatio(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 0.85; // Taller for desktop
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 0.8;
    }
    return 0.75;
  }

  static double getGridCrossAxisSpacing(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 24;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 16;
    }
    return 12;
  }

  static double getGridMainAxisSpacing(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return 24;
    } else if (ScreenBreakpoints.isTablet(context)) {
      return 18;
    }
    return 16;
  }

  // ============== SAFE CONTENT PADDING ==============

  static EdgeInsets getSafeContentPadding(BuildContext context) {
    if (ScreenBreakpoints.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    } else if (ScreenBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }
}
