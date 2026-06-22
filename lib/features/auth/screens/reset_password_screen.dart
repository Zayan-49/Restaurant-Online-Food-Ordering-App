import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/features/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_card_container.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_header.dart';

/// Reset Password screen - third step of password recovery flow.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    ref.read(resetPasswordNewProvider.notifier).state =
        _newPasswordController.text;
    ref.read(resetPasswordConfirmProvider.notifier).state =
        _confirmPasswordController.text;

    final success = await ref.read(authControllerProvider).resetPassword();
    if (success && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resetPasswordLoadingProvider);
    final passwordVisible = ref.watch(passwordVisibilityProvider);
    final confirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);
    final isFormValid = ref.watch(resetPasswordFormValidProvider);
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
                        onTap: () => context.go('/otp-verification'),
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
                    AppStrings.resetPasswordTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.resetPasswordSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 18.h : 24.h),

                  // New Password Input
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !passwordVisible,
                    onChanged: (v) =>
                        ref.read(resetPasswordNewProvider.notifier).state = v,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isDesktop ? 15.0 : 16.sp,
                        ),
                    decoration: InputDecoration(
                      labelText: AppStrings.newPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          ref
                              .read(passwordVisibilityProvider.notifier)
                              .state = !passwordVisible;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 10.h : 12.h),

                  // Confirm Password Input
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !confirmPasswordVisible,
                    onChanged: (v) => ref
                        .read(resetPasswordConfirmProvider.notifier)
                        .state = v,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isDesktop ? 15.0 : 16.sp,
                        ),
                    decoration: InputDecoration(
                      labelText: AppStrings.confirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          confirmPasswordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          ref
                              .read(confirmPasswordVisibilityProvider.notifier)
                              .state = !confirmPasswordVisible;
                        },
                      ),
                    ),
                  ),

                  // Password validation message
                  if (_newPasswordController.text.isNotEmpty &&
                      _confirmPasswordController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        _newPasswordController.text !=
                                _confirmPasswordController.text
                            ? AppStrings.passwordsDoNotMatch
                            : _newPasswordController.text.length < 6
                                ? AppStrings.passwordTooShort
                                : 'Passwords match ✓',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _newPasswordController.text !=
                                      _confirmPasswordController.text
                                  ? Colors.red
                                  : _newPasswordController.text.length < 6
                                      ? Colors.orange
                                      : Colors.green,
                              fontSize: isDesktop ? 12.0 : 12.sp,
                            ),
                      ),
                    ),

                  SizedBox(height: isDesktop ? 18.h : 24.h),

                  // Reset Password Button
                  AuthButton(
                    label: AppStrings.resetPasswordButton,
                    isLoading: isLoading,
                    onPressed: isFormValid ? _handleResetPassword : () {},
                  ),
                  SizedBox(height: isDesktop ? 14.h : 18.h),

                  // Back to Login
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        AppStrings.backToLogin,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: isDesktop ? 13.0 : 14.sp,
                            ),
                      ),
                    ),
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


