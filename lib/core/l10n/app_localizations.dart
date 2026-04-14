import 'package:flutter/material.dart';

/// Lightweight EN/AR strings (no codegen). Expand as you add screens.
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'AppLocalizations not found');
    return result!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  bool get isRtl => locale.languageCode == 'ar';

  String _t(String en, String ar) => isRtl ? ar : en;

  // Bottom nav
  String get navHome => _t('Home', 'الرئيسية');
  String get navCourses => _t('Courses', 'الدورات');
  String get navLearning => _t('My Learning', 'تعلّمي');
  String get navCertificates => _t('Certificates', 'الشهادات');
  String get navProfile => _t('Profile', 'حسابي');
  String get statHours => _t('Hours', 'ساعات');

  // Profile
  String get student => _t('Student', 'طالب');
  String get proMember => _t('Pro Member', 'عضو برو');
  String get editProfile => _t('Edit Profile', 'تعديل الملف');
  String get changePassword => _t('Change Password', 'تغيير كلمة المرور');
  String get notificationPrefs => _t('Notification preferences', 'إعدادات الإشعارات');
  String get myCourses => _t('My Courses', 'دوراتي');
  String get paymentHistory => _t('Payment History', 'سجل المدفوعات');
  String get certificates => _t('Certificates', 'الشهادات');
  String get helpSupport => _t('Help & Support', 'المساعدة');
  String get settings => _t('Settings', 'الإعدادات');
  String get signOut => _t('Sign Out', 'تسجيل الخروج');
  String get account => _t('Account', 'الحساب');
  String get learning => _t('Learning', 'التعلم');
  String get support => _t('Support', 'الدعم');

  // Edit profile
  String get editProfileTitle => _t('Edit Profile', 'تعديل الملف الشخصي');
  String get fullName => _t('Full name', 'الاسم الكامل');
  String get email => _t('Email', 'البريد الإلكتروني');
  String get phone => _t('Phone', 'رقم الهاتف');
  String get saveChanges => _t('Save changes', 'حفظ التغييرات');
  String get profileUpdated => _t('Profile updated', 'تم تحديث الملف');

  // Settings (subset)
  String get settingsTitle => _t('Settings', 'الإعدادات');
  String get appearance => _t('Appearance', 'المظهر');
  String get darkMode => _t('Dark Mode', 'الوضع الداكن');
  String get darkModeDesc => _t('Switch to dark theme', 'تفعيل المظهر الداكن');
  String get arabicLanguage => _t('Arabic Language', 'اللغة العربية');
  String get arabicDesc => _t('RTL layout & Arabic text', 'تخطيط من اليمين لليسار');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
