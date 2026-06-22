import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/checkout/screens/checkout_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/product/screens/product_details_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/splash/screens/splash_screen.dart';

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
  static const String editProfile = '/edit-profile';
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
  static const String editProfile = 'editProfile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
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
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      name: AppRouteNames.productDetails,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProductDetailsScreen(),
      ),
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
      path: AppRoutes.editProfile,
      name: AppRouteNames.editProfile,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: EditProfileScreen(),
      ),
    ),
  ],
);
