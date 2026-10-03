import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:online_food_ordering/core/config/app_config.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/features/shared/auth/screens/forgot_password_screen.dart';
import 'package:online_food_ordering/features/shared/auth/screens/login_screen.dart';
import 'package:online_food_ordering/features/shared/auth/screens/otp_verification_screen.dart';
import 'package:online_food_ordering/features/shared/auth/screens/register_screen.dart';
import 'package:online_food_ordering/features/shared/auth/screens/reset_password_screen.dart';
import 'package:online_food_ordering/features/customer/cart/screens/cart_screen.dart';
import 'package:online_food_ordering/features/customer/checkout/screens/checkout_screen.dart';
import 'package:online_food_ordering/core/models/food_model.dart' as model;
import 'package:online_food_ordering/features/customer/home/screens/home_screen.dart';
import 'package:online_food_ordering/features/customer/orders/screens/orders_screen.dart';
import 'package:online_food_ordering/features/customer/onboarding/screens/onboarding_screen.dart';
import 'package:online_food_ordering/features/customer/product/screens/product_details_screen.dart';
import 'package:online_food_ordering/features/customer/profile/screens/edit_profile_screen.dart';
import 'package:online_food_ordering/features/shared/splash/screens/splash_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/admin_shell_screen.dart';

import 'package:online_food_ordering/features/customer/orders/screens/order_history_screen.dart';

import 'package:online_food_ordering/features/customer/profile/screens/privacy_security_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderHistory = '/order-history';
  static const String editProfile = '/edit-profile';
  static const String privacySecurity = '/privacy-security';
  static const String adminShell = '/admin';
}

class AppRouteNames {
  AppRouteNames._();
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String otpVerification = 'otpVerification';
  static const String resetPassword = 'resetPassword';
  static const String home = 'home';
  static const String productDetails = 'productDetails';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orders = 'orders';
  static const String orderHistory = 'orderHistory';
  static const String editProfile = 'editProfile';
  static const String privacySecurity = 'privacySecurity';
  static const String adminShell = 'adminShell';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final user = SupabaseConfig.client.auth.currentUser;
    final loc = state.matchedLocation;

    final isAuthRoute = loc == AppRoutes.login ||
        loc == AppRoutes.register ||
        loc == AppRoutes.forgotPassword ||
        loc == AppRoutes.otpVerification ||
        loc == AppRoutes.resetPassword;

    final isPublicRoute = loc == AppRoutes.splash ||
        loc == AppRoutes.onboarding ||
        isAuthRoute;

    // 1. If NOT logged in and trying to access ANY protected route -> Redirect to Login
    if (user == null && !isPublicRoute) {
      return AppRoutes.login;
    }

    // 2. If logged in and trying to access Auth screens (Login/Register) -> Redirect to Home
    if (user != null && isAuthRoute) {
      return AppRoutes.home;
    }

    // 3. If accessing Admin route -> Verify Role from Supabase
    final isAdminRoute = loc.startsWith(AppRoutes.adminShell);
    if (isAdminRoute && user != null) {
      try {
        final profile = await SupabaseConfig.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null || profile['role'] != 'restaurant_admin') {
          return AppRoutes.login;
        }
      } catch (e) {
        return AppRoutes.login;
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRouteNames.register,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: RegisterScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRouteNames.forgotPassword,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.otpVerification,
      name: AppRouteNames.otpVerification,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: OtpVerificationScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: AppRouteNames.resetPassword,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ResetPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRouteNames.home,
      pageBuilder: (context, state) => NoTransitionPage(
        child: Consumer(
          builder: (context, ref, child) {
            final config = ref.watch(appConfigProvider);
            if (config.appType == AppType.restaurant) {
              return const AdminShellScreen();
            }
            return const HomeScreen();
          },
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminShell,
      name: AppRouteNames.adminShell,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: AdminShellScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      name: AppRouteNames.productDetails,
      pageBuilder: (context, state) {
        // SAFE NAVIGATION: Check if extra is valid FoodModel
        final extra = state.extra;
        if (extra is model.FoodModel) {
          return NoTransitionPage(
            child: ProductDetailsScreen(food: extra),
          );
        }
        
        // Fallback: Redirect to home if data is missing (common on web refresh)
        return const NoTransitionPage(
          child: HomeScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: AppRouteNames.cart,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CartScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: AppRouteNames.checkout,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.orders,
      name: AppRouteNames.orders,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: OrdersScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.orderHistory,
      name: AppRouteNames.orderHistory,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: OrderHistoryScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.editProfile,
      name: AppRouteNames.editProfile,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.privacySecurity,
      name: AppRouteNames.privacySecurity,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: PrivacySecurityScreen(),
      ),
    ),
  ],
);
