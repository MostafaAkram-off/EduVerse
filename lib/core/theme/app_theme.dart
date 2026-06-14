import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

// ============================================================
// APP THEME — EduVerse
// Wires AppColors + AppTextTheme into Flutter ThemeData.
// No hex codes or raw font sizes live here.
// ============================================================

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme — all values come from AppColors
      colorScheme: const ColorScheme.light(
        primary:              AppColors.primary,
        onPrimary:            AppColors.textOnPrimary,
        primaryContainer:     AppColors.primaryLight,
        onPrimaryContainer:   AppColors.primaryDark,
        secondary:            AppColors.secondary,
        onSecondary:          AppColors.textOnPrimary,
        error:                AppColors.error,
        onError:              AppColors.textOnPrimary,
        errorContainer:       AppColors.errorLight,
        surface:              AppColors.surface,
        onSurface:            AppColors.textPrimary,
        surfaceContainerHighest: AppColors.background,
        outline:              AppColors.border,
        outlineVariant:       AppColors.borderLight,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // Typography — comes from AppTextTheme
      fontFamily:  AppTextTheme.fontFamily,
      textTheme:   AppTextTheme.materialTheme,

      // ── Component themes ──────────────────
      appBarTheme:              _appBarTheme(),
      elevatedButtonTheme:      _elevatedButtonTheme(),
      outlinedButtonTheme:      _outlinedButtonTheme(),
      textButtonTheme:          _textButtonTheme(),
      inputDecorationTheme:     _inputDecorationTheme(),
      cardTheme:                _cardTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(),
      chipTheme:                _chipTheme(),
      dividerTheme:             _dividerTheme(),
      switchTheme:              _switchTheme(),
      sliderTheme:              _sliderTheme(),
      progressIndicatorTheme:   _progressIndicatorTheme(),
      snackBarTheme:            _snackBarTheme(),
      dialogTheme:              _dialogTheme(),
      bottomSheetTheme:         _bottomSheetTheme(),
      tabBarTheme:              _tabBarTheme(),
      floatingActionButtonTheme: _fabTheme(),

      // Ripple
      splashColor:    AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),

      // Page transitions (iOS feel on both platforms)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────
  static ThemeData get dark {
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary:              AppColors.primary,
        onPrimary:            AppColors.textOnPrimary,
        primaryContainer:     Color(0xFF1E2D6B),
        onPrimaryContainer:   AppColors.primaryLight,
        secondary:            AppColors.secondary,
        onSecondary:          AppColors.textOnPrimary,
        error:                AppColors.error,
        onError:              AppColors.textOnPrimary,
        errorContainer:       Color(0xFF4A1010),
        surface:              AppColors.darkSurface,
        onSurface:            AppColors.darkText,
        surfaceContainerHighest: AppColors.darkBackground,
        outline:              AppColors.darkBorder,
        outlineVariant:       AppColors.darkSurface,
      ),

      textTheme: AppTextTheme.materialThemeDark,

      appBarTheme: _appBarTheme().copyWith(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.darkText,
        titleTextStyle: AppTextTheme.appBarTitle.colored(AppColors.darkText),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:           Colors.transparent,
          statusBarIconBrightness:  Brightness.light,
          statusBarBrightness:      Brightness.dark,
        ),
      ),

      cardTheme: _cardTheme().copyWith(
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      inputDecorationTheme: _inputDecorationTheme().copyWith(
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        hintStyle: AppTextTheme.inputHint.colored(AppColors.darkTextMuted),
      ),

      bottomNavigationBarTheme: _bottomNavTheme().copyWith(
        backgroundColor:     AppColors.darkCard,
        unselectedItemColor: AppColors.darkTextMuted,
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.darkBorder,
        thickness: 1,
        space:     0,
      ),

      snackBarTheme: _snackBarTheme().copyWith(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: AppTextTheme.bodyMedium.colored(AppColors.darkText),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTextTheme.labelLarge,
        unselectedLabelStyle: AppTextTheme.labelMedium,
        dividerColor: AppColors.darkBorder,
      ),

      // Dialog — dark surface + adaptive text
      dialogTheme: _dialogTheme().copyWith(
        backgroundColor: AppColors.darkSurface,
        titleTextStyle: AppTextTheme.displaySmall.colored(AppColors.darkText),
        contentTextStyle: AppTextTheme.bodyMedium.colored(AppColors.darkTextSecondary),
      ),

      // Bottom sheet — use dark card so text is readable
      bottomSheetTheme: _bottomSheetTheme().copyWith(
        backgroundColor: AppColors.darkCard,
      ),
    );
  }
}


// ═════════════════════════════════════════
// COMPONENT THEME BUILDERS
// Private — only AppTheme uses these.
// ═════════════════════════════════════════

AppBarTheme _appBarTheme() => AppBarTheme(
  backgroundColor: AppColors.card,
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleTextStyle: AppTextTheme.appBarTitle,
  iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
  systemOverlayStyle: const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness:     Brightness.light,
  ),
);

ElevatedButtonThemeData _elevatedButtonTheme() =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextTheme.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );

OutlinedButtonThemeData _outlinedButtonTheme() =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextTheme.buttonMedium,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );

TextButtonThemeData _textButtonTheme() =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextTheme.buttonSmall,
      ),
    );

InputDecorationTheme _inputDecorationTheme() =>
    InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle:  AppTextTheme.inputHint,
      labelStyle: AppTextTheme.inputLabel.colored(AppColors.textSecondary),
      floatingLabelStyle: AppTextTheme.inputLabel.colored(AppColors.primary),
    );

CardThemeData _cardTheme() => CardThemeData(
  color: AppColors.card,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: AppColors.borderLight, width: 1),
  ),
  margin: const EdgeInsets.only(bottom: 8),
);

BottomNavigationBarThemeData _bottomNavTheme() =>
    BottomNavigationBarThemeData(
      backgroundColor:      AppColors.card,
      selectedItemColor:    AppColors.primary,
      unselectedItemColor:  AppColors.textTertiary,
      selectedLabelStyle:   AppTextTheme.navActive,
      unselectedLabelStyle: AppTextTheme.navInactive,
      showUnselectedLabels: true,
      type:      BottomNavigationBarType.fixed,
      elevation: 0,
    );

ChipThemeData _chipTheme() => ChipThemeData(
  backgroundColor:   AppColors.card,
  selectedColor:     AppColors.primary,
  labelStyle:        AppTextTheme.labelMedium,
  secondaryLabelStyle: AppTextTheme.labelMedium.colored(AppColors.textOnPrimary),
  side: const BorderSide(color: AppColors.border, width: 1.5),
  shape: const StadiumBorder(),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
);

DividerThemeData _dividerTheme() => const DividerThemeData(
  color:     AppColors.borderLight,
  thickness: 1,
  space:     0,
);

SwitchThemeData _switchTheme() => SwitchThemeData(
  thumbColor: WidgetStateProperty.all(AppColors.card),
  trackColor: WidgetStateProperty.resolveWith((states) =>
  states.contains(WidgetState.selected)
      ? AppColors.primary
      : AppColors.border,
  ),
  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
);

SliderThemeData _sliderTheme() => const SliderThemeData(
  activeTrackColor:   AppColors.primary,
  inactiveTrackColor: AppColors.borderLight,
  thumbColor:         AppColors.primary,
  overlayColor:       Color(0x204A6CF7),
  trackHeight:        4,
  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
);

ProgressIndicatorThemeData _progressIndicatorTheme() =>
    const ProgressIndicatorThemeData(
      color:              AppColors.primary,
      linearTrackColor:   AppColors.borderLight,
      linearMinHeight:    8,
    );

SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
  backgroundColor:   AppColors.textPrimary,
  contentTextStyle:  AppTextTheme.bodyMedium.colored(AppColors.textOnPrimary),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  behavior: SnackBarBehavior.floating,
);

DialogThemeData _dialogTheme() => DialogThemeData(
  backgroundColor: AppColors.card,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  titleTextStyle:   AppTextTheme.displaySmall,
  contentTextStyle: AppTextTheme.bodyMedium,
);

BottomSheetThemeData _bottomSheetTheme() => const BottomSheetThemeData(
  backgroundColor: AppColors.card,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  elevation:        0,
  modalElevation:   0,
  dragHandleColor:  AppColors.borderLight,
  dragHandleSize:   Size(40, 4),
);

TabBarThemeData _tabBarTheme() => TabBarThemeData(
  labelColor:           AppColors.primary,
  unselectedLabelColor: AppColors.textSecondary,
  indicatorColor:       AppColors.primary,
  indicatorSize:        TabBarIndicatorSize.tab,
  labelStyle:           AppTextTheme.labelLarge,
  unselectedLabelStyle: AppTextTheme.labelMedium,
  dividerColor:         AppColors.border,
);

FloatingActionButtonThemeData _fabTheme() =>
    const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      shape: CircleBorder(),
    );

// ─────────────────────────────────────────
// USAGE — main.dart
// ─────────────────────────────────────────
//
// void main() => runApp(const EduVerseApp());
//
// class EduVerseApp extends StatelessWidget {
//   const EduVerseApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'EduVerse',
//       debugShowCheckedModeBanner: false,
//       theme:     AppTheme.light,
//       darkTheme: AppTheme.dark,
//       themeMode: ThemeMode.system,
//       home: const SplashScreen(),
//     );
//   }
// }