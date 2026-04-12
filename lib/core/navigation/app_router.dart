import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/onboarding/ui/screens/splash_screen.dart';
import 'package:edu_verse/features/onboarding/ui/screens/onboarding_screen.dart';
import 'package:edu_verse/features/auth/login/ui/screens/login_screen.dart';
import 'package:edu_verse/features/auth/register/ui/screens/register_screen.dart';
import 'package:edu_verse/features/auth/register/ui/screens/email_verification_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/screens/forgot_password_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/screens/verify_otp_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/screens/reset_password_screen.dart';
import 'package:edu_verse/features/main_scaffold/ui/screens/student_main_screen.dart';
import 'package:edu_verse/features/main_scaffold/ui/screens/instructor_main_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VerifyOtpScreen(
            email: extra['email'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email: extra['email'] as String? ?? '',
            code: extra['code'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        builder: (context, state) => const StudentMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.instructorHome,
        builder: (context, state) => const InstructorMainScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: \${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}