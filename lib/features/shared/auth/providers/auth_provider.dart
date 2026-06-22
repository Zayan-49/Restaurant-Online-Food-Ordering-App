import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Providers for authentication UI state (local-only, no backend).

// ===== LOGIN SCREEN =====
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final authLoadingProvider = StateProvider<bool>((ref) => false);

final authFormValidProvider = Provider<bool>((ref) {
  final email = ref.watch(emailProvider);
  final password = ref.watch(passwordProvider);
  return email.trim().isNotEmpty && email.contains('@') && password.trim().isNotEmpty;
});

// ===== GOOGLE LOGIN =====
final googleLoadingProvider = StateProvider<bool>((ref) => false);

// ===== REGISTER SCREEN =====
final registerFullNameProvider = StateProvider<String>((ref) => '');
final registerEmailProvider = StateProvider<String>((ref) => '');
final registerPhoneProvider = StateProvider<String>((ref) => '');
final registerPasswordProvider = StateProvider<String>((ref) => '');
final registerConfirmPasswordProvider = StateProvider<String>((ref) => '');
final registerLoadingProvider = StateProvider<bool>((ref) => false);
final registerPasswordVisibilityProvider = StateProvider<bool>((ref) => false);
final registerConfirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);

final registerFormValidProvider = Provider<bool>((ref) {
  final fullName = ref.watch(registerFullNameProvider);
  final email = ref.watch(registerEmailProvider);
  final phone = ref.watch(registerPhoneProvider);
  final password = ref.watch(registerPasswordProvider);
  final confirmPassword = ref.watch(registerConfirmPasswordProvider);

  return fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      email.contains('@') &&
      phone.trim().isNotEmpty &&
      phone.length >= 10 &&
      password.trim().isNotEmpty &&
      password.length >= 6 &&
      password == confirmPassword;
});

// ===== FORGOT PASSWORD FLOW =====
final forgotPasswordEmailProvider = StateProvider<String>((ref) => '');
final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);

// ===== OTP VERIFICATION =====
final otpProvider = StateProvider<String>((ref) => '');
final otpLoadingProvider = StateProvider<bool>((ref) => false);
final otpResendCountdownProvider = StateProvider<int>((ref) => 0);

// ===== RESET PASSWORD =====
final resetPasswordNewProvider = StateProvider<String>((ref) => '');
final resetPasswordConfirmProvider = StateProvider<String>((ref) => '');
final resetPasswordLoadingProvider = StateProvider<bool>((ref) => false);
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);

/// Validation providers
final resetPasswordFormValidProvider = Provider<bool>((ref) {
  final newPass = ref.watch(resetPasswordNewProvider);
  final confirmPass = ref.watch(resetPasswordConfirmProvider);

  if (newPass.trim().isEmpty || confirmPass.trim().isEmpty) return false;
  if (newPass.length < 6) return false;
  if (newPass != confirmPass) return false;
  return true;
});

final otpValidProvider = Provider<bool>((ref) {
  final otp = ref.watch(otpProvider);
  return otp.length == 6; // 6-digit OTP
});

/// Auth controller for simulating auth flows
class AuthController {
  AuthController(this._ref);
  final Ref _ref;

  Future<bool> signIn() async {
    final isValid = _ref.read(authFormValidProvider);
    if (!isValid) return false;

    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 900 + Random().nextInt(600)));
      return true;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> register() async {
    final isValid = _ref.read(registerFormValidProvider);
    if (!isValid) return false;

    _ref.read(registerLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 900 + Random().nextInt(600)));
      return true;
    } finally {
      _ref.read(registerLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> sendOtp() async {
    _ref.read(forgotPasswordLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(400)));
      _ref.read(otpResendCountdownProvider.notifier).state = 60;
      _startResendCountdown();
      return true;
    } finally {
      _ref.read(forgotPasswordLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> verifyOtp() async {
    final isValid = _ref.read(otpValidProvider);
    if (!isValid) return false;

    _ref.read(otpLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(400)));
      return true;
    } finally {
      _ref.read(otpLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> resetPassword() async {
    final isValid = _ref.read(resetPasswordFormValidProvider);
    if (!isValid) return false;

    _ref.read(resetPasswordLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 900 + Random().nextInt(600)));
      return true;
    } finally {
      _ref.read(resetPasswordLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _ref.read(googleLoadingProvider.notifier).state = true;
    try {
      await Future.delayed(Duration(milliseconds: 1200 + Random().nextInt(800)));
      return true;
    } finally {
      _ref.read(googleLoadingProvider.notifier).state = false;
    }
  }

  void _startResendCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _ref.read(otpResendCountdownProvider);
      if (remaining > 1) {
        _ref.read(otpResendCountdownProvider.notifier).state = remaining - 1;
      } else {
        timer.cancel();
        _ref.read(otpResendCountdownProvider.notifier).state = 0;
      }
    });
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});


