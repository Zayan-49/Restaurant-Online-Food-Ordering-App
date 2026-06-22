import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_card_container.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_footer_text.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_textfield.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_header.dart';

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
                        onPressed: () => context.go('/login'),
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
                    AppStrings.forgotPasswordTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getHeadlineMediumFontSize(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.forgotPasswordSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@restaurant.com',
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: AppStrings.sendOtpButton,
                    isLoading: isLoading,
                    onPressed: _handleSendOtp,
                  ),
                  const SizedBox(height: 24),
                  AuthFooterText(
                    text: 'Remember your password?',
                    actionText: 'Log In',
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
