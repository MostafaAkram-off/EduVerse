import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();
  static final AppPreferences instance = AppPreferences._();

  static const _kDarkMode          = 'app_dark_mode';
  static const _kName              = 'profile_display_name';
  static const _kEmail             = 'profile_email';
  static const _kPhone             = 'profile_phone';
  static const _kSpecialization    = 'profile_specialization';
  static const _kOnboardingSeen    = 'onboarding_seen';
  static const _kProfilePicture    = 'profile_picture_filename';
  static const _kToken             = 'auth_token';
  static const _kRefreshToken      = 'auth_refresh_token';
  static const _kRole              = 'auth_role';
  static const _kUserId            = 'auth_user_id';

  bool    _loaded      = false;
  bool    _darkMode    = false;
  bool    _onboardingSeen = false;
  String  _userName    = '';
  String  _userEmail   = '';
  String  _userPhone   = '';
  String  _userSpecialization = '';
  String  _profilePictureFilename = '';
  String? _savedToken;
  String? _savedRefreshToken;
  String? _savedRole;
  String? _savedUserId;

  bool    get loaded       => _loaded;
  bool    get darkMode     => _darkMode;
  bool    get hasSeenOnboarding => _onboardingSeen;
  String  get userName             => _userName;
  String  get userEmail            => _userEmail;
  String  get userPhone            => _userPhone;
  String  get userSpecialization   => _userSpecialization;
  String  get profilePictureFilename => _profilePictureFilename;
  bool    get hasSession   => _savedToken != null && _savedToken!.isNotEmpty;
  String? get savedToken   => _savedToken;
  String? get savedRefreshToken => _savedRefreshToken;
  String? get savedRole    => _savedRole;
  String? get savedUserId  => _savedUserId;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _darkMode            = p.getBool(_kDarkMode) ?? false;
    _onboardingSeen      = p.getBool(_kOnboardingSeen) ?? false;
    _userName               = p.getString(_kName) ?? '';
    _userEmail              = p.getString(_kEmail) ?? '';
    _userPhone              = p.getString(_kPhone) ?? '';
    _userSpecialization     = p.getString(_kSpecialization) ?? '';
    _profilePictureFilename = p.getString(_kProfilePicture) ?? '';
    _savedToken          = p.getString(_kToken);
    _savedRefreshToken   = p.getString(_kRefreshToken);
    _savedRole           = p.getString(_kRole);
    _savedUserId         = p.getString(_kUserId);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setOnboardingSeen() async {
    if (_onboardingSeen) return;
    _onboardingSeen = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboardingSeen, true);
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDarkMode, value);
  }

  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required String role,
    required String userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    _savedToken        = token;
    _savedRefreshToken = refreshToken;
    _savedRole         = role;
    _savedUserId       = userId;
    _userName          = name;
    _userEmail         = email;
    if (phone != null && phone.isNotEmpty) _userPhone = phone;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    if (refreshToken != null) await p.setString(_kRefreshToken, refreshToken);
    await p.setString(_kRole, role);
    await p.setString(_kUserId, userId);
    await p.setString(_kName, name);
    await p.setString(_kEmail, email);
    if (phone != null && phone.isNotEmpty) await p.setString(_kPhone, phone);
  }

  Future<void> clearSession() async {
    _savedToken        = null;
    _savedRefreshToken = null;
    _savedRole         = null;
    _savedUserId       = null;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kRefreshToken);
    await p.remove(_kRole);
    await p.remove(_kUserId);
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    String? specialization,
  }) async {
    _userName  = name.trim();
    _userEmail = email.trim();
    _userPhone = phone.trim();
    if (specialization != null) _userSpecialization = specialization.trim();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, _userName);
    await p.setString(_kEmail, _userEmail);
    await p.setString(_kPhone, _userPhone);
    if (specialization != null) {
      await p.setString(_kSpecialization, _userSpecialization);
    }
  }

  Future<void> saveProfilePicture(String filename) async {
    _profilePictureFilename = filename;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kProfilePicture, filename);
  }

  Future<void> clearProfilePicture() async {
    _profilePictureFilename = '';
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kProfilePicture);
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
