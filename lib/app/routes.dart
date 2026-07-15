import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/local_storage.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/profile/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/settings_page.dart';

/// Route path constants.
class AppRoutes {
  AppRoutes._();
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Builds the app router with auth-aware redirects.
GoRouter createRouter({
  required AuthBloc authBloc,
  required LocalStorage localStorage,
}) {
  const authRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.otp,
    AppRoutes.onboarding,
  };

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final location = state.matchedLocation;

      // Wait on the splash while the initial status resolves.
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthed = status == AuthStatus.authenticated;
      final onAuthRoute = authRoutes.contains(location);

      if (!isAuthed) {
        if (location == AppRoutes.splash) {
          return localStorage.onboardingSeen
              ? AppRoutes.login
              : AppRoutes.onboarding;
        }
        // Allow auth routes; redirect everything else to login.
        return onAuthRoute ? null : AppRoutes.login;
      }

      // Authenticated users should not sit on splash/auth screens.
      if (location == AppRoutes.splash || onAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          // Deep link supplies ?token=...
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, __) => const OtpPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsPage(),
      ),
    ],
  );
}

/// Adapts a [Stream] into a [Listenable] so GoRouter re-evaluates redirects
/// whenever the auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
