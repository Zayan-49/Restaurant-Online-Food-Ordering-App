import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/screen_breakpoints.dart';
import '../../../routes/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_bottom_controls.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  void _handleNext(int currentIndex, int totalPages) {
    final controller = ref.read(onboardingPageControllerProvider);
    if (currentIndex == totalPages - 1) {
      context.go(AppRoutes.login);
      return;
    }
    if (!controller.hasClients) return;
    controller.animateToPage(
      currentIndex + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleSkip() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingIndexProvider);
    final pages = ref.watch(onboardingPagesProvider);
    final controller = ref.watch(onboardingPageControllerProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 24, tablet: 32, desktop: 48);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = ScreenBreakpoints.isDesktop(context);
            final isTablet = ScreenBreakpoints.isTablet(context);
            final maxWidth = ResponsiveHelper.getMaxWidth(context);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: ResponsiveHelper.getAdaptiveSize(context,
                        mobile: 20, tablet: 24, desktop: 32),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: OnboardingPageView(
                          controller: controller,
                          pages: pages,
                          currentIndex: currentIndex,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          onPageChanged: (index) => ref
                              .read(onboardingIndexProvider.notifier)
                              .setPage(index),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OnboardingDotsIndicator(
                        currentIndex: currentIndex,
                        itemCount: pages.length,
                      ),
                      const SizedBox(height: 24),
                      OnboardingBottomControls(
                        isLastPage: currentIndex == pages.length - 1,
                        onSkip: _handleSkip,
                        onNext: () => _handleNext(currentIndex, pages.length),
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
