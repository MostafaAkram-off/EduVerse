import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:edu_verse/config/di/di.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/navigation/app_router.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_theme_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.instance.load();
  configureDependencies();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const EduVerseApp());
}

class EduVerseApp extends StatefulWidget {
  const EduVerseApp({super.key});

  @override
  State<EduVerseApp> createState() => _EduVerseAppState();
}

class _EduVerseAppState extends State<EduVerseApp> {
  final AppPreferences _prefs = AppPreferences.instance;

  @override
  void initState() {
    super.initState();
    _prefs.addListener(_onPrefsChanged);
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _prefs.locale;

    return MaterialApp.router(
      title: 'EduVerse',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppThemeBuilder.light(locale),
      darkTheme: AppThemeBuilder.dark(locale),
      themeMode: _prefs.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
