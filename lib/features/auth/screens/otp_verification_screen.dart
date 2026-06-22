import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/features/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/auth/widgets/auth_header.dart';
import 'package:online_food_ordering/features/auth/widgets/otp_input_field.dart';

/// OTP Verification screen - second step of password recovery flow.
/// Fully responsive with overflow-free layout.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  void _handleVerifyOtp() async {
    final success = await ref.read(authControllerProvider).verifyOtp();
    if (success && mounted) {
      context.go('/reset-password');
    }
  }

  void _handleResendOtp() async {
    await ref.read(authControllerProvider).sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(otpLoadingProvider);
    final otpValid = ref.watch(otpValidProvider);
    final resendCountdown = ref.watch(otpResendCountdownProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    // Responsive padding
    final verticalPadding = isDesktop ? 16.h : 24.h;
    final horizontalPadding = isDesktop ? 8.w : 12.w;

    // Container width constraints
    late final double containerWidth;
    if (isDesktop) {
      containerWidth = min(480.0, screenWidth * 0.4);
    } else if (isTablet) {
      containerWidth = min(450.0, screenWidth * 0.85);
    } else {
      containerWidth = screenWidth * 0.92;
    }

    // Adaptive spacing
    final headerSpacing = isDesktop ? 16.h : 24.h;
    final titleSpacing = 6.h;
    final otpSectionSpacing = isDesktop ? 20.h : 28.h;
    final buttonSpacing = isDesktop ? 12.h : 16.h;
    final resendSpacing = isDesktop ? 10.h : 14.h;

    return Scaffold(
      // Keyboard avoidance
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 450),
                  opacity: _visible ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 450),
                    scale: _visible ? 1 : 0.98,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: containerWidth),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 18.w : 20.w,
                            vertical: isDesktop ? 20.h : 24.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header with back button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.go('/forgot-password'),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 18.w,
                                      ),
                                    ),
                                  ),
                                  const Flexible(child: AuthHeader()),
                                  SizedBox(width: 24.w),
                                ],
                              ),
                              SizedBox(height: headerSpacing),

                              // Title
                              Text(
                                AppStrings.otpVerificationTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: isDesktop ? 22.0 : null,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: titleSpacing),

                              // Subtitle with responsive text handling
                              Text(
                                AppStrings.otpVerificationSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: isDesktop ? 13.0 : 14.sp,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: otpSectionSpacing),

                              // OTP Input Fields with overflow handling
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: OtpInputField(
                                  onChanged: (value) {
                                    ref.read(otpProvider.notifier).state =
                                        value;
                                  },
                                ),
                              ),
                              SizedBox(height: otpSectionSpacing),

                              // Verify Button with responsive sizing
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: containerWidth - 40.w,
                                ),
                                child: AuthButton(
                                  label: AppStrings.verifyButton,
                                  isLoading: isLoading,
                                  onPressed: otpValid ? _handleVerifyOtp : () {},
                                ),
                              ),
                              SizedBox(height: buttonSpacing),

                              // Resend Code section with responsive text
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Didn\'t receive the code?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: isDesktop ? 12.0 : 12.sp,
                                            ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                      SizedBox(height: resendSpacing),
                                      if (resendCountdown > 0)
                                        Text(
                                          'Resend in ${resendCountdown}s',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize:
                                                    isDesktop ? 13.0 : 14.sp,
                                              ),
                                          textAlign: TextAlign.center,
                                        )
                                      else
                                        TextButton(
                                          onPressed: _handleResendOtp,
                                          style: TextButton.styleFrom(
                                            padding:
                                                EdgeInsets.symmetric(
                                              horizontal: isDesktop ? 6.w : 8.w,
                                              vertical: 0,
                                            ),
                                          ),
                                          child: Text(
                                            AppStrings.resendCode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize:
                                                      isDesktop ? 13.0 : 14.sp,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


