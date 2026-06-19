import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:edu_verse/core/constants/app_assets.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/features/auth/shared/user_data.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Text
  late final AnimationController _textCtrl;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;

  // Floating blobs
  late final AnimationController _blobCtrl;

  // Bottom loader
  late final AnimationController _loaderCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const ElasticOutCurve(0.75)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl, curve: const Interval(0.0, 0.35, curve: Curves.easeIn)),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _textCtrl,
                curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)));
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.3, 0.8, curve: Curves.easeIn)));

    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _loaderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _loaderCtrl.repeat();
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final prefs = AppPreferences.instance;
      if (prefs.hasSession) {
        AuthSession.set(
          UserData(
            id: prefs.savedUserId ?? '',
            name: prefs.userName,
            email: prefs.userEmail,
            role: UserRole.fromString(prefs.savedRole ?? 'Student'),
          ),
          token: prefs.savedToken!,
          refreshToken: prefs.savedRefreshToken,
        );
        final isInstructor =
            prefs.savedRole?.toLowerCase() == 'instructor';
        context.go(
          isInstructor ? AppRoutes.instructorHome : AppRoutes.studentHome,
        );
      } else if (prefs.hasSeenOnboarding) {
        context.go(AppRoutes.login);
      } else {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _blobCtrl.dispose();
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gradient background ──────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF6A3DE8), AppColors.secondary],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Animated blobs ───────────────────────────────────
          AnimatedBuilder(
            animation: _blobCtrl,
            builder: (_, __) => CustomPaint(
              painter: _BlobPainter(_blobCtrl.value),
            ),
          ),

          // ── Glassmorphism card ───────────────────────────────
          Center(
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Image.asset(
                        AppAssets.logoFull,
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  ClipRect(
                    child: SlideTransition(
                      position: _nameSlide,
                      child: FadeTransition(
                        opacity: _nameFade,
                        child: Text(
                          'EduVerse',
                          style: AppTextTheme.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tagline
                  ClipRect(
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Training Center Management',
                          style: AppTextTheme.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Shimmer loader bar at bottom ─────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _loaderCtrl,
                  builder: (_, __) {
                    return Center(
                      child: SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: null,
                          backgroundColor: Colors.white.withValues(alpha: 0.20),
                          color: Colors.white.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 3,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Powered by EduVerse',
                  style: AppTextTheme.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.50),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating blob painter ────────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    _drawBlob(
      canvas,
      size,
      paint,
      color: Colors.white.withValues(alpha: 0.07),
      cx: size.width * 0.15 + math.sin(t * 2 * math.pi) * 20,
      cy: size.height * 0.18 + math.cos(t * 2 * math.pi) * 16,
      radius: 110,
    );
    _drawBlob(
      canvas,
      size,
      paint,
      color: Colors.white.withValues(alpha: 0.05),
      cx: size.width * 0.88 + math.cos(t * 2 * math.pi + 1) * 18,
      cy: size.height * 0.25 + math.sin(t * 2 * math.pi + 1) * 14,
      radius: 130,
    );
    _drawBlob(
      canvas,
      size,
      paint,
      color: Colors.white.withValues(alpha: 0.06),
      cx: size.width * 0.10 + math.cos(t * 2 * math.pi + 2) * 14,
      cy: size.height * 0.78 + math.sin(t * 2 * math.pi + 2) * 20,
      radius: 150,
    );
    _drawBlob(
      canvas,
      size,
      paint,
      color: Colors.white.withValues(alpha: 0.04),
      cx: size.width * 0.82 + math.sin(t * 2 * math.pi + 3) * 22,
      cy: size.height * 0.80 + math.cos(t * 2 * math.pi + 3) * 12,
      radius: 120,
    );
  }

  void _drawBlob(Canvas canvas, Size size, Paint paint,
      {required Color color,
      required double cx,
      required double cy,
      required double radius}) {
    paint.color = color;
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}
