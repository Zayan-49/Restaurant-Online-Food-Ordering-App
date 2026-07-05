import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_button.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_header.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/auth_textfield.dart';
import 'package:online_food_ordering/features/shared/auth/widgets/forgot_password_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    ref.read(emailProvider.notifier).state = _emailController.text;
    ref.read(passwordProvider.notifier).state = _passwordController.text;

    try {
      final appType = await ref.read(authControllerProvider).signIn();
      if (appType != null && mounted) {
        // Redirection happens automatically via IndexedStack/Router logic
        // but we force navigation to home to refresh the shell.
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final cardWidth = ResponsiveHelper.getAuthCardMaxWidth(context);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: _visible ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 450),
                scale: _visible ? 1 : 0.98,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthHeader(),
                            const SizedBox(height: 24),
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'user@example.com',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              isPassword: true,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ForgotPasswordText(
                                onTap: () => context.go('/forgot-password'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              label: 'Log In',
                              isLoading: isLoading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text('Don\'t have an account?'),
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
