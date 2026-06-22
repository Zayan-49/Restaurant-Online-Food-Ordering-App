import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_header.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/otp_input_field.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_card_container.dart';

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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/forgot-password'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: 20,
                      ),
                      const Spacer(),
                      const AuthHeader(),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.otpVerificationTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getHeadlineMediumFontSize(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.otpVerificationSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  OtpInputField(
                    onChanged: (value) {
                      ref.read(otpProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    label: AppStrings.verifyButton,
                    isLoading: isLoading,
                    onPressed: otpValid ? _handleVerifyOtp : () {},
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: ResponsiveHelper.getBodySmallFontSize(context),
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (resendCountdown > 0)
                        Text(
                          'Resend in ${resendCountdown}s',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _handleResendOtp,
                          child: Text(
                            AppStrings.resendCode,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                            ),
                          ),
                        ),
                    ],
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
