import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/features/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_card_container.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_footer_text.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_textfield.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_header.dart';

/// Forgot Password screen - first step of password recovery flow.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    ref.read(forgotPasswordEmailProvider.notifier).state = _emailController.text;
    final success = await ref.read(authControllerProvider).sendOtp();
    if (success && mounted) {
      context.go('/otp-verification');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(forgotPasswordLoadingProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 450),
          opacity: _visible ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 450),
            scale: _visible ? 1 : 0.98,
            child: AuthCardContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20.w,
                        ),
                      ),
                      const Spacer(),
                      const AuthHeader(),
                      const Spacer(),
                      SizedBox(width: 20.w),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 20.h : 28.h),

                  // Title & Subtitle
                  Text(
                    AppStrings.forgotPasswordTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.forgotPasswordSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 18.h : 24.h),

                  // Email Input
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@restaurant.com',
                  ),
                  SizedBox(height: isDesktop ? 16.h : 22.h),

                  // Send OTP Button
                  AuthButton(
                    label: AppStrings.sendOtpButton,
                    isLoading: isLoading,
                    onPressed: _handleSendOtp,
                  ),
                  SizedBox(height: isDesktop ? 16.h : 20.h),

                  // Back to Login
                  AuthFooterText(
                    text: 'Remember your password?',
                    actionText: AppStrings.backToLogin,
                    onActionTap: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


