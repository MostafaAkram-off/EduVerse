import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_main_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.instructorHome,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.instructorHome,
        builder: (_, __) => const InstructorMainScreen(),
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
