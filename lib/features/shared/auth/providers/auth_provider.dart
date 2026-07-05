import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/config/app_config.dart';

/// Stream provider to track the real-time Supabase Auth state.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

/// Provider for the current Supabase User.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? SupabaseConfig.client.auth.currentUser;
});

/// Provider for user role from profiles table.
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    
    return response?['role'] as String?;
  } catch (e) {
    return null;
  }
});

// ===== UI STATE PROVIDERS =====
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Registration Providers
final registerFullNameProvider = StateProvider<String>((ref) => '');
final registerEmailProvider = StateProvider<String>((ref) => '');
final registerPasswordProvider = StateProvider<String>((ref) => '');
final registerConfirmPasswordProvider = StateProvider<String>((ref) => '');
final registerLoadingProvider = StateProvider<bool>((ref) => false);

// Forgot Password / OTP / Reset Providers
final forgotPasswordEmailProvider = StateProvider<String>((ref) => '');
final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);
final otpProvider = StateProvider<String>((ref) => '');
final otpLoadingProvider = StateProvider<bool>((ref) => false);
final otpResendCountdownProvider = StateProvider<int>((ref) => 0);
final otpValidProvider = StateProvider<bool>((ref) => false);
final resetPasswordNewProvider = StateProvider<String>((ref) => '');
final resetPasswordConfirmProvider = StateProvider<String>((ref) => '');
final resetPasswordLoadingProvider = StateProvider<bool>((ref) => false);

// Authentication Controller
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this._ref);
  final Ref _ref;
  final _supabase = SupabaseConfig.client;

  /// Sign In with Dynamic Role Detection
  Future<AppType?> signIn() async {
    final email = _ref.read(emailProvider);
    final password = _ref.read(passwordProvider);

    if (email.isEmpty || password.isEmpty) return null;

    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', response.user!.id)
          .maybeSingle();
      
      if (profile == null) {
        await _supabase.auth.signOut();
        throw Exception('User profile not found. Verification might be pending.');
      }

      final userRole = profile['role'] as String;
      final detectedType = userRole == 'restaurant_admin' 
          ? AppType.restaurant 
          : AppType.customer;

      _ref.read(appConfigProvider.notifier).setConfig(detectedType);

      return detectedType;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Register a new user
  Future<bool> signUp() async {
    final email = _ref.read(registerEmailProvider);
    final password = _ref.read(registerPasswordProvider);
    final fullName = _ref.read(registerFullNameProvider);

    if (email.isEmpty || password.isEmpty) return false;

    _ref.read(registerLoadingProvider.notifier).state = true;
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
          'role': 'customer',
        });
      }
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(registerLoadingProvider.notifier).state = false;
    }
  }

  /// Full Logout - Terminates Supabase session and resets local app state.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    // Reset app back to customer mode defaults
    _ref.read(appConfigProvider.notifier).setConfig(AppType.customer);
  }

  /// Send password reset email (Zabardasti OTP flow)
  Future<bool> sendOtp() async {
    final email = _ref.read(forgotPasswordEmailProvider);
    if (email.isEmpty) return false;

    _ref.read(forgotPasswordLoadingProvider.notifier).state = true;
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false,
      );
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(forgotPasswordLoadingProvider.notifier).state = false;
    }
  }

  /// Verify recovery OTP
  Future<bool> verifyOtp() async {
    final email = _ref.read(forgotPasswordEmailProvider);
    final token = _ref.read(otpProvider);
    
    if (email.isEmpty || token.isEmpty) return false;

    _ref.read(otpLoadingProvider.notifier).state = true;
    try {
      await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: token,
        type: OtpType.email,
      );
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(otpLoadingProvider.notifier).state = false;
    }
  }

  /// Update password
  Future<bool> resetPassword() async {
    final newPassword = _ref.read(resetPasswordNewProvider);
    
    if (newPassword.isEmpty) return false;

    _ref.read(resetPasswordLoadingProvider.notifier).state = true;
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(resetPasswordLoadingProvider.notifier).state = false;
    }
  }
}
