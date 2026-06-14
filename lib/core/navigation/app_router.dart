import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:edu_verse/core/navigation/app_routes.dart';

// Onboarding
import 'package:edu_verse/features/onboarding/ui/screens/splash_screen.dart';
import 'package:edu_verse/features/onboarding/ui/screens/onboarding_screen.dart';
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_cubit.dart';

// Auth — Login
import 'package:edu_verse/features/auth/login/ui/screens/login_screen.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_cubit.dart';

// Auth — Register
import 'package:edu_verse/features/auth/register/ui/screens/register_screen.dart';
import 'package:edu_verse/features/auth/register/ui/screens/email_verification_screen.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_cubit.dart';

// Auth — Forgot Password
import 'package:edu_verse/features/auth/forgot_password/ui/screens/forgot_password_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/screens/verify_otp_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/screens/reset_password_screen.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/cubit/forgot_password_cubit.dart';

// Instructor
import 'package:edu_verse/features/instructor/ui/screens/instructor_main_screen.dart';

// Student
import 'package:edu_verse/features/student/ui/screens/student_main_screen.dart';

// Settings
import 'package:edu_verse/core/screens/settings_screen.dart';

final _sl = GetIt.instance;

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => BlocProvider(
          create: (_) => _sl<OnboardingCubit>(),
          child: const OnboardingScreen(),
        ),
      ),

      // ── Login ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => BlocProvider(
          create: (_) => _sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),

      // ── Register ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => BlocProvider(
          create: (_) => _sl<RegisterCubit>(),
          child: const RegisterScreen(),
        ),
        routes: [
          GoRoute(
            path: 'verify-email',
            builder: (_, state) => BlocProvider(
              create: (_) => _sl<RegisterCubit>(),
              child: const EmailVerificationScreen(),
            ),
          ),
        ],
      ),

      // ── Forgot Password ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => BlocProvider(
          create: (_) => _sl<ForgotPasswordCubit>(),
          child: const ForgotPasswordScreen(),
        ),
        routes: [
          GoRoute(
            path: 'verify-otp',
            builder: (_, state) => BlocProvider(
              create: (_) => _sl<ForgotPasswordCubit>(),
              child: const VerifyOtpScreen(),
            ),
          ),
          GoRoute(
            path: 'reset-password',
            builder: (_, state) => BlocProvider(
              create: (_) => _sl<ForgotPasswordCubit>(),
              child: const ResetPasswordScreen(),
            ),
          ),
        ],
      ),

      // ── Instructor ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.instructorHome,
        builder: (_, __) => const InstructorMainScreen(),
      ),

      // ── Student ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentHome,
        builder: (_, __) => const StudentMainScreen(),
      ),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
          ],
        ),
      ),
    ),
  );
}
