import 'package:flutter/material.dart';

/// BuildContext shortcuts for theme-aware colors.
/// Use these in every widget instead of hardcoded AppColors for surfaces/text.
///
/// Example:
///   color: context.surface      → white in light, dark card in dark
///   color: context.bg           → grey50 in light, dark900 in dark
///   style: context.textPrimary  → Color(0xFF111827) in light, white in dark
extension ThemeExt on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Surfaces
  Color get bg      => cs.surfaceContainerHighest;   // scaffold bg
  Color get surface => cs.surface;                    // card / container bg
  Color get surfaceVariant => isDark
      ? const Color(0xFF1E293B)
      : const Color(0xFFF5F7FB);

  // Text
  Color get textPrimary   => cs.onSurface;
  Color get textSecondary => isDark
      ? const Color(0xFF94A3B8)
      : const Color(0xFF6B7280);
  Color get textTertiary => isDark
      ? const Color(0xFF475569)
      : const Color(0xFF9CA3AF);

  // Border
  Color get border      => cs.outline;
  Color get borderLight => cs.outlineVariant;

  // Brand (always the same)
  Color get primary   => cs.primary;
  Color get secondary => cs.secondary;

  // Status
  Color get error   => cs.error;
  Color get success => const Color(0xFF22C55E);
  Color get warning => const Color(0xFFF59E0B);

  // Divider
  Color get divider => isDark
      ? const Color(0xFF334155)
      : const Color(0xFFF3F4F6);
}
