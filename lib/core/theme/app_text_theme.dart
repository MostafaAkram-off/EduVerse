import 'package:flutter/material.dart';
import 'app_colors.dart';

// ============================================================
// APP TEXT THEME — EduVerse
// Single source of truth for all typography.
//
// DARK MODE RULE:
//   - Do NOT set color: on styles that should follow the theme.
//   - With color: null, Flutter inherits from DefaultTextStyle
//     which is driven by Theme.of(context).colorScheme.onSurface.
//   - Light → onSurface = AppColors.textPrimary (dark)
//   - Dark  → onSurface = AppColors.darkText     (light)
//   - Only set explicit color on brand/always-colored styles
//     (certTitle, link, navActive, price…).
// ============================================================

class AppTextTheme {
  AppTextTheme._();

  // ─────────────────────────────────────────
  // FONT FAMILY
  // ─────────────────────────────────────────
  static const String fontFamily = 'SF Pro Display';

  // ─────────────────────────────────────────
  // DISPLAY / HEADINGS
  // color: null → inherits onSurface from theme
  // ─────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ─────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  // bodySmall is secondary — slightly muted but still inherits theme color.
  // Widgets needing secondary color call .colored(context.textSecondary).
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─────────────────────────────────────────
  // LABELS
  // ─────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ─────────────────────────────────────────
  // SCREEN / APPBAR
  // ─────────────────────────────────────────

  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle appBarSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────
  // CARDS
  // ─────────────────────────────────────────

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────
  // STATS
  // ─────────────────────────────────────────

  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ─────────────────────────────────────────
  // PRICE — always brand primary color
  // ─────────────────────────────────────────

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  // ─────────────────────────────────────────
  // BUTTONS — no color (set via ButtonStyle)
  // ─────────────────────────────────────────

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ─────────────────────────────────────────
  // GREETING
  // ─────────────────────────────────────────

  static const TextStyle greeting = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle greetingName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  // ─────────────────────────────────────────
  // SECTION HEADER (uppercase group labels)
  // ─────────────────────────────────────────

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  // ─────────────────────────────────────────
  // BADGES — no color, callers provide it
  // ─────────────────────────────────────────

  static const TextStyle badgeSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle badgeMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ─────────────────────────────────────────
  // PROGRESS / GRADE
  // ─────────────────────────────────────────

  static const TextStyle progressValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle gradeHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1.0,
  );

  // ─────────────────────────────────────────
  // CERTIFICATE — always white on gradient
  // ─────────────────────────────────────────

  static const TextStyle certTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnPrimary,   // intentional: white on gradient bg
  );

  static const TextStyle certLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,   // intentional: white on gradient bg
    letterSpacing: 1.5,
  );

  // ─────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────

  static const TextStyle navActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,         // intentional: always brand blue
  );

  static const TextStyle navInactive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // ─────────────────────────────────────────
  // INPUT
  // ─────────────────────────────────────────

  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────
  // METADATA / TIMESTAMPS
  // ─────────────────────────────────────────

  static const TextStyle timestamp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────
  // LINK — always primary color
  // ─────────────────────────────────────────

  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,         // intentional: always brand blue
  );

  // ─────────────────────────────────────────
  // MATERIAL TextTheme MAPPING
  // ─────────────────────────────────────────

  static const TextTheme materialTheme = TextTheme(
    displayLarge:   displayLarge,
    displayMedium:  displayMedium,
    displaySmall:   displaySmall,
    headlineLarge:  displayMedium,
    headlineMedium: displaySmall,
    headlineSmall:  TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge:   bodyLarge,
    bodyMedium:  bodyMedium,
    bodySmall:   bodySmall,
    labelLarge:  labelLarge,
    labelMedium: labelMedium,
    labelSmall:  labelSmall,
    titleLarge:  cardTitle,
    titleMedium: appBarTitle,
    titleSmall:  TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  // Dark mode — same scale, light text via theme's onSurface
  static TextTheme get materialThemeDark => materialTheme.apply(
    bodyColor:    AppColors.darkText,
    displayColor: AppColors.darkText,
  );
}

// ─────────────────────────────────────────
// EXTENSION — quick TextStyle modifiers
// ─────────────────────────────────────────
extension TextStyleX on TextStyle {
  TextStyle colored(Color c)   => copyWith(color: c);
  TextStyle sized(double s)    => copyWith(fontSize: s);
  TextStyle semibold()         => copyWith(fontWeight: FontWeight.w600);
  TextStyle bold()             => copyWith(fontWeight: FontWeight.w700);
  TextStyle extraBold()        => copyWith(fontWeight: FontWeight.w800);
  TextStyle black()            => copyWith(fontWeight: FontWeight.w900);
  TextStyle italic()           => copyWith(fontStyle: FontStyle.italic);
  TextStyle spaced(double ls)  => copyWith(letterSpacing: ls);
  TextStyle lined(double h)    => copyWith(height: h);
}
