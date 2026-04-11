import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists theme, locale, and profile fields. Listen with [ListenableBuilder].
class AppPreferences extends ChangeNotifier {
  AppPreferences._();
  static final AppPreferences instance = AppPreferences._();

  static const _kDarkMode = 'app_dark_mode';
  static const _kLocale = 'app_locale';
  static const _kName = 'profile_display_name';
  static const _kEmail = 'profile_email';
  static const _kPhone = 'profile_phone';

  bool _loaded = false;
  bool _darkMode = false;
  String _localeCode = 'en';
  String _userName = 'Ahmed Khalid';
  String _userEmail = 'ahmed.khalid@edu.com';
  String _userPhone = '+20 100 000 0000';

  bool get loaded => _loaded;
  bool get darkMode => _darkMode;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _darkMode = p.getBool(_kDarkMode) ?? false;
    _localeCode = p.getString(_kLocale) ?? 'en';
    if (_localeCode != 'en' && _localeCode != 'ar') _localeCode = 'en';
    _userName = p.getString(_kName) ?? _userName;
    _userEmail = p.getString(_kEmail) ?? _userEmail;
    _userPhone = p.getString(_kPhone) ?? _userPhone;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDarkMode, value);
  }

  Future<void> setLocaleCode(String code) async {
    final c = code == 'ar' ? 'ar' : 'en';
    if (_localeCode == c) return;
    _localeCode = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLocale, c);
  }

  Future<void> setArabicEnabled(bool arabic) => setLocaleCode(arabic ? 'ar' : 'en');

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _userName = name.trim();
    _userEmail = email.trim();
    _userPhone = phone.trim();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, _userName);
    await p.setString(_kEmail, _userEmail);
    await p.setString(_kPhone, _userPhone);
  }

  String initials() {
    final parts = _userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b'.toUpperCase();
  }
}
