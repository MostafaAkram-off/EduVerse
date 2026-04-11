import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Applies [AppTheme] and optional Cairo font for Arabic locales.
class AppThemeBuilder {
  AppThemeBuilder._();

  static ThemeData light(Locale locale) {
    final base = AppTheme.light;
    return _mergeFont(base, locale);
  }

  static ThemeData dark(Locale locale) {
    final base = AppTheme.dark;
    return _mergeFont(base, locale);
  }

  static ThemeData _mergeFont(ThemeData base, Locale locale) {
    if (locale.languageCode != 'ar') return base;
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );
  }
}
