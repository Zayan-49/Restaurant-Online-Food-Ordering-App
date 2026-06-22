import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/screen_breakpoints.dart';
import '../../../routes/app_router.dart';
import '../widgets/splash_loader.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_tagline.dart';
/// Luxury splash screen with subtle motion and automatic routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  static const Duration _animationDuration = Duration(milliseconds: 850);
  static const Duration _delayDuration = Duration(seconds: 3);
  bool _isVisible = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isVisible = true);
    });
    _timer = Timer(_delayDuration, _navigateNext);
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  void _navigateNext() {
    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = ScreenBreakpoints.isDesktop(context);
            final isTablet = ScreenBreakpoints.isTablet(context);
            final horizontalPadding = constraints.maxWidth > 900 ? 40.w : 24.w;
            final bottomPadding = constraints.maxHeight > 700 ? 28.h : 18.h;
            final contentMaxWidth = isDesktop
                ? 420.w
                : isTablet
                    ? 420.w
                    : 380.w;
            final logoSize = isDesktop
                ? 124.r
                : isTablet
                    ? 134.r
                    : 124.r;
            final topGap = isDesktop
                ? 18.h
                : isTablet
                    ? 24.h
                    : 20.h;
            final contentGap = isDesktop
                ? 10.h
                : isTablet
                    ? 16.h
                    : 14.h;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20.h,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: AnimatedOpacity(
                        duration: _animationDuration,
                        opacity: _isVisible ? 1 : 0,
                        curve: Curves.easeOut,
                        child: AnimatedScale(
                          duration: _animationDuration,
                          scale: _isVisible ? 1 : 0.96,
                          curve: Curves.easeOutCubic,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SplashLogo(size: logoSize),
                              SizedBox(height: topGap),
                              SplashTagline(isDesktop: isDesktop),
                              SizedBox(height: contentGap),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: const SplashLoader(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
