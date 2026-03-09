import 'package:flutter/material.dart';

// ============================================================
// APP COLORS — EduVerse
// All colors defined once here, named semantically.
// Import this file everywhere instead of writing hex codes.
// ============================================================

class AppColors {
  AppColors._();

  // ─────────────────────────────────────────
  // RAW PALETTE  (hex → named Color)
  // Only place in the entire app where hex codes live.
  // ─────────────────────────────────────────

  // Blues / Indigo
  static const Color indigoPure        = Color(0xFF4A6CF7);
  static const Color indigoLight       = Color(0xFFEEF1FE);
  static const Color indigoDark        = Color(0xFF3451D1);
  static const Color indigoDeep        = Color(0xFF667EEA);

  // Purple
  static const Color purplePure        = Color(0xFF7C3AED);
  static const Color purpleCard        = Color(0xFF764BA2);

  // Green
  static const Color greenPure         = Color(0xFF22C55E);
  static const Color greenLight        = Color(0xFFDCFCE7);
  static const Color greenDark         = Color(0xFF059669);

  // Amber
  static const Color amberPure         = Color(0xFFF59E0B);
  static const Color amberLight        = Color(0xFFFEF3C7);

  // Red
  static const Color redPure           = Color(0xFFEF4444);
  static const Color redLight          = Color(0xFFFEE2E2);

  // Neutrals — Light
  static const Color grey50            = Color(0xFFF5F7FB); // page background
  static const Color grey100           = Color(0xFFF3F4F6); // border light
  static const Color grey200           = Color(0xFFE5E7EB); // border
  static const Color grey400           = Color(0xFF9CA3AF); // tertiary text
  static const Color grey500           = Color(0xFF6B7280); // secondary text
  static const Color grey900           = Color(0xFF111827); // primary text
  static const Color white             = Color(0xFFFFFFFF);

  // Neutrals — Dark
  static const Color dark900           = Color(0xFF0F172A); // dark page bg
  static const Color dark800           = Color(0xFF1E293B); // dark card
  static const Color dark700           = Color(0xFF334155); // dark border
  static const Color dark600           = Color(0xFF475569); // dark muted text
  static const Color dark200           = Color(0xFF94A3B8); // dark secondary text
  static const Color dark50            = Color(0xFFF1F5F9); // dark primary text


  // ─────────────────────────────────────────
  // SEMANTIC TOKENS
  // Use these everywhere in widgets & themes.
  // To rebrand — only touch the raw palette above.
  // ─────────────────────────────────────────

  // Brand
  static const Color primary           = indigoPure;
  static const Color primaryLight      = indigoLight;
  static const Color primaryDark       = indigoDark;
  static const Color secondary         = purplePure;

  // Status
  static const Color success           = greenPure;
  static const Color successLight      = greenLight;
  static const Color successDark       = greenDark;

  static const Color warning           = amberPure;
  static const Color warningLight      = amberLight;

  static const Color error             = redPure;
  static const Color errorLight        = redLight;

  // Surfaces
  static const Color background        = grey50;
  static const Color surface           = white;
  static const Color card              = white;

  // Text
  static const Color textPrimary       = grey900;
  static const Color textSecondary     = grey500;
  static const Color textTertiary      = grey400;
  static const Color textOnPrimary     = white;
  static const Color textOnDark        = dark50;

  // Border
  static const Color border            = grey200;
  static const Color borderLight       = grey100;

  // Icons
  static const Color iconDefault       = grey400;
  static const Color iconPrimary       = indigoPure;
  static const Color iconSuccess       = greenPure;
  static const Color iconWarning       = amberPure;
  static const Color iconError         = redPure;

  // Gradient stops
  static const Color gradient1Start    = indigoPure;   // primary gradient
  static const Color gradient1End      = purplePure;
  static const Color gradient2Start    = greenPure;    // success gradient
  static const Color gradient2End      = greenDark;
  static const Color gradient3Start    = amberPure;    // warning gradient
  static const Color gradient3End      = redPure;
  static const Color gradientCard1     = indigoDeep;   // card gradient
  static const Color gradientCard2     = purpleCard;

  // Shimmer
  static const Color shimmerBase       = Color(0xFFF0F0F0);
  static const Color shimmerHighlight  = Color(0xFFE0E0E0);

  // Overlay / Scrim
  static Color get scrimLight          => grey900.withValues(alpha: 0.40);
  static Color get scrimDark           => dark900.withValues(alpha: 0.70);

  // ─────────────────────────────────────────
  // DARK MODE SEMANTIC TOKENS
  // ─────────────────────────────────────────
  static const Color darkBackground    = dark900;
  static const Color darkSurface       = dark800;
  static const Color darkCard          = dark800;
  static const Color darkBorder        = dark700;
  static const Color darkText          = dark50;
  static const Color darkTextSecondary = dark200;
  static const Color darkTextMuted     = dark600;
}