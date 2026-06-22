import 'package:flutter/material.dart';
import '../responsive/screen_breakpoints.dart';
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isMobile => ScreenBreakpoints.isMobile(this);
  bool get isTablet => ScreenBreakpoints.isTablet(this);
  bool get isDesktop => ScreenBreakpoints.isDesktop(this);
}
