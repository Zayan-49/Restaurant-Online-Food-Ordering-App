import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import 'onboarding_content.dart';
import 'onboarding_image.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.controller,
    required this.pages,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isDesktop,
    required this.isTablet,
  });

  final PageController controller;
  final List<OnboardingModel> pages;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      onPageChanged: onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final model = pages[index];
        final isActive = index == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardingImage(
                model: model,
                isActive: isActive,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              const SizedBox(height: 32),
              OnboardingContent(
                model: model,
                isActive: isActive,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
            ],
          ),
        );
      },
    );
  }
}
