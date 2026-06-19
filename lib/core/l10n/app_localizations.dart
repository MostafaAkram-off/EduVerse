import 'package:flutter/material.dart';

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

  // ── Bottom nav ──────────────────────────────────────────────
  String get navHome         => _t('Home',         'الرئيسية');
  String get navCourses      => _t('Courses',      'الدورات');
  String get navLearning     => _t('My Learning',  'تعلّمي');
  String get navCertificates => _t('Certificates', 'الشهادات');
  String get navProfile      => _t('Profile',      'حسابي');

  // ── Auth — Login ────────────────────────────────────────────
  String get welcomeBack      => _t('Welcome Back!',           'مرحباً بعودتك!');
  String get signInSubtitle   => _t('Sign in to continue',     'سجّل دخولك للمتابعة');
  String get emailLabel       => _t('Email',                   'البريد الإلكتروني');
  String get emailHint        => _t('Enter your email',        'أدخل بريدك الإلكتروني');
  String get passwordLabel    => _t('Password',                'كلمة المرور');
  String get passwordHint     => _t('Enter your password',     'أدخل كلمة المرور');
  String get forgotPassword   => _t('Forgot Password?',        'نسيت كلمة المرور؟');
  String get signIn           => _t('Sign In',                 'تسجيل الدخول');
  String get orContinueWith   => _t('or continue with',        'أو تابع بواسطة');
  String get continueGoogle   => _t('Continue with Google',    'تابع بحساب Google');
  String get noAccount        => _t("Don't have an account?",  'ليس لديك حساب؟');
  String get signUp           => _t('Sign Up',                 'إنشاء حساب');
  String get comingSoon       => _t('Coming soon',             'قريباً');

  // ── Auth — Register ─────────────────────────────────────────
  String get createAccount       => _t('Create Account',                              'إنشاء حساب');
  String get joinLearners        => _t('Join thousands of learners today',            'انضم لآلاف المتعلمين اليوم');
  String get fullName            => _t('Full name',                                   'الاسم الكامل');
  String get fullNameHint        => _t('Enter your full name',                        'أدخل اسمك الكامل');
  String get phoneOptional       => _t('Phone number',                               'رقم الهاتف');
  String get phoneHint           => _t('Enter your phone number',                    'أدخل رقم هاتفك');
  String get dateOfBirth         => _t('Date of birth',                              'تاريخ الميلاد');
  String get iAmA                => _t('I am a...',                                  'أنا...');
  String get studentRole         => _t('Student',                                    'طالب');
  String get studentRoleDesc     => _t('Browse & enroll in courses',                 'تصفح الدورات وسجّل فيها');
  String get instructorRole      => _t('Instructor',                                 'مدرّب');
  String get instructorRoleDesc  => _t('Manage sessions & courses',                  'أدر الجلسات والدورات');
  String get createPasswordHint  => _t('Create a password',                          'أنشئ كلمة مرور');
  String get confirmPassword     => _t('Confirm Password',                           'تأكيد كلمة المرور');
  String get confirmPasswordHint => _t('Re-enter your password',                     'أعد إدخال كلمة المرور');
  String get termsText           => _t('By signing up, you agree to our Terms & Privacy Policy',
                                       'بإنشاء حساب، توافق على الشروط وسياسة الخصوصية');
  String get alreadyHaveAccount  => _t('Already have an account?',                   'لديك حساب بالفعل؟');

  // Validators
  String get fieldRequired       => _t('This field is required',                     'هذا الحقل مطلوب');
  String get validEmail          => _t('Enter a valid email',                        'أدخل بريداً صحيحاً');
  String get passwordMinLength   => _t('Password must be at least 6 characters',    'كلمة المرور 6 أحرف على الأقل');
  String get passwordsNoMatch    => _t('Passwords do not match',                     'كلمتا المرور غير متطابقتين');
  String get selectBirthDate     => _t('Please select your date of birth',           'الرجاء اختيار تاريخ ميلادك');

  // ── Auth — Email Verification ───────────────────────────────
  String get verifyEmailTitle    => _t('Verify Your Email',                          'تحقق من بريدك');
  String get verifyEmailSent     => _t('We sent a 6-digit code to',                  'أرسلنا رمزاً مكوناً من 6 أرقام إلى');
  String get didntReceive        => _t("Didn't receive?",                            'لم تستلمه؟');
  String get resendCode          => _t('Resend Code',                               'إعادة إرسال الرمز');
  String get resending           => _t('Resending...',                              'جاري الإرسال...');
  String get verifyEmailBtn      => _t('Verify Email',                              'تحقق من البريد');
  String get enterSixDigit       => _t('Please enter the 6-digit code',             'أدخل الرمز المكوّن من 6 أرقام');
  String get emailVerifiedMsg    => _t('Email verified! Please sign in.',            'تم التحقق! سجّل دخولك.');
  String resendIn(int s)         => _t('Resend in ${s}s',                           'إعادة الإرسال بعد $s ث');

  // ── Auth — Forgot Password ──────────────────────────────────
  String get forgotPasswordTitle  => _t('Forgot Password?',          'نسيت كلمة المرور؟');
  String get forgotPasswordSub    => _t('Enter your email and we\'ll send a reset link',
                                        'أدخل بريدك وسنرسل رابط الاستعادة');
  String get sendResetLink        => _t('Send Reset Link',           'إرسال رابط الاستعادة');
  String get enterResetCode       => _t('Enter Reset Code',          'أدخل رمز الاستعادة');
  String get resetCodeSent        => _t('We sent a 6-digit code to', 'أرسلنا رمزاً من 6 أرقام إلى');
  String get verifyCode           => _t('Verify Code',               'تحقق من الرمز');
  String get newPassword          => _t('New Password',              'كلمة المرور الجديدة');
  String get newPasswordHint      => _t('Enter new password',        'أدخل كلمة المرور الجديدة');
  String get resetPassword        => _t('Reset Password',            'استعادة كلمة المرور');

  // ── Student Home ────────────────────────────────────────────
  String get goodMorning       => _t('Good Morning 🌤️',       'صباح الخير 🌤️');
  String get goodAfternoon     => _t('Good Afternoon ☀️',     'مساء الخير ☀️');
  String get goodEvening       => _t('Good Evening 🌙',       'مساء النور 🌙');
  String get coursesLabel      => _t('Courses',               'الدورات');
  String get completedLabel    => _t('Completed',             'مكتمل');
  String get statHours         => _t('Hours',                 'ساعات');
  String get continueLearning  => _t('Continue Learning',     'واصل التعلم');
  String get resume            => _t('Resume',                'استكمال');
  String get popularCourses    => _t('Popular Courses',       'الدورات الشائعة');
  String get enrolledCourses   => _t('Enrolled Courses',      'دوراتي');
  String get viewAll           => _t('View All',              'عرض الكل');
  String get noCoursesYet      => _t('No courses enrolled yet','لم تسجّل في أي دورة بعد');
  String get browseCoursesHint => _t('Browse courses and start learning','تصفح الدورات وابدأ التعلم');

  // ── Courses List ────────────────────────────────────────────
  String get exploreCourses    => _t('Explore Courses',       'استكشف الدورات');
  String get searchHint        => _t('Search courses...',     'ابحث عن دورات...');
  String get allCategories     => _t('All',                   'الكل');
  String get noCoursesFound    => _t('No courses found',      'لا توجد دورات');

  // ── Course Detail ───────────────────────────────────────────
  String get aboutCourse       => _t('About',                 'عن الدورة');
  String get sessionsTab       => _t('Sessions',              'الجلسات');
  String get assignmentsTab    => _t('Assignments',           'الواجبات');
  String get enrollNow         => _t('Enroll Now',            'سجّل الآن');
  String get alreadyEnrolled   => _t('Enrolled',              'مسجّل');
  String get durationLabel     => _t('Duration',              'المدة');
  String get studentsLabel     => _t('Students',              'الطلاب');
  String get levelLabel        => _t('Level',                 'المستوى');
  String get noSessions        => _t('No sessions available', 'لا جلسات متاحة');
  String get noAssignments     => _t('No assignments',        'لا واجبات');

  // ── Sessions ────────────────────────────────────────────────
  String get upcoming          => _t('Upcoming',              'قادمة');
  String get ongoing           => _t('Ongoing',               'جارية');
  String get past              => _t('Past',                  'منتهية');
  String get joinSession       => _t('Join Session',          'انضم للجلسة');
  String get mySessions        => _t('My Sessions',           'جلساتي');
  String get noUpcoming        => _t('No upcoming sessions',  'لا جلسات قادمة');

  // ── My Learning ─────────────────────────────────────────────
  String get myLearningTitle   => _t('My Learning',           'تعلّمي');
  String get inProgress        => _t('In Progress',           'جاري');
  String get completedCourses  => _t('Completed',             'مكتملة');
  String get progressLabel     => _t('Progress',              'التقدم');
  String get continueBtn       => _t('Continue',              'متابعة');
  String get reviewBtn         => _t('Review',                'مراجعة');

  // ── Certificates ────────────────────────────────────────────
  String get certificatesTitle => _t('Certificates',          'الشهادات');
  String get downloadCert      => _t('Download',              'تحميل');
  String get noCertificates    => _t('No certificates yet',   'لا شهادات بعد');
  String get completeCourseForCert => _t('Complete a course to earn your certificate',
                                         'أكمل دورة للحصول على شهادتك');

  // ── Notifications ───────────────────────────────────────────
  String get notificationsTitle => _t('Notifications',        'الإشعارات');
  String get markAllRead        => _t('Mark all read',        'تعليم الكل كمقروء');
  String get noNotifications    => _t('No notifications yet', 'لا إشعارات بعد');

  // ── Assignments ─────────────────────────────────────────────
  String get uploadAssignment  => _t('Upload Assignment',     'رفع الواجب');
  String get submitAssignment  => _t('Submit',                'إرسال');
  String get assignmentDue     => _t('Due',                   'الموعد النهائي');

  // ── Profile ─────────────────────────────────────────────────
  String get student           => _t('Student',               'طالب');
  String get instructor        => _t('Instructor',            'مدرّب');
  String get proMember         => _t('Pro Member',            'عضو برو');
  String get editProfile       => _t('Edit Profile',          'تعديل الملف');
  String get changePassword    => _t('Change Password',       'تغيير كلمة المرور');
  String get notificationPrefs => _t('Notification preferences', 'إعدادات الإشعارات');
  String get myCourses         => _t('My Courses',            'دوراتي');
  String get paymentHistory    => _t('Payment History',       'سجل المدفوعات');
  String get certificates      => _t('Certificates',          'الشهادات');
  String get helpSupport       => _t('Help & Support',        'المساعدة');
  String get settings          => _t('Settings',              'الإعدادات');
  String get signOut           => _t('Sign Out',              'تسجيل الخروج');
  String get account           => _t('Account',               'الحساب');
  String get learning          => _t('Learning',              'التعلم');
  String get support           => _t('Support',               'الدعم');

  // ── Edit Profile ────────────────────────────────────────────
  String get editProfileTitle  => _t('Edit Profile',          'تعديل الملف الشخصي');
  String get phone             => _t('Phone',                 'رقم الهاتف');
  String get saveChanges       => _t('Save changes',          'حفظ التغييرات');
  String get profileUpdated    => _t('Profile updated',       'تم تحديث الملف');

  // ── Settings ────────────────────────────────────────────────
  String get settingsTitle        => _t('Settings',                      'الإعدادات');
  String get customizeExperience  => _t('Customize your experience',     'خصّص تجربتك');
  String get appearance           => _t('Appearance',                    'المظهر');
  String get darkMode             => _t('Dark Mode',                     'الوضع الداكن');
  String get darkModeDesc         => _t('Switch to dark theme',          'تفعيل المظهر الداكن');
  String get arabicLanguage       => _t('Arabic Language',               'اللغة العربية');
  String get arabicDesc           => _t('RTL layout & Arabic text',      'تخطيط من اليمين لليسار');

  // ── Instructor ──────────────────────────────────────────────
  String get dashboard         => _t('Dashboard',             'لوحة التحكم');
  String get totalStudents     => _t('Total Students',        'إجمالي الطلاب');
  String get totalSessions     => _t('Total Sessions',        'إجمالي الجلسات');
  String get upcomingSession   => _t('Upcoming Session',      'الجلسة القادمة');
  String get myStudents        => _t('My Students',           'طلابي');
  String get manageCourses     => _t('Manage Courses',        'إدارة الدورات');
  String get addSession        => _t('Add Session',           'إضافة جلسة');
  String get noStudents        => _t('No students yet',       'لا طلاب بعد');

  // ── Enrollment / Payment ────────────────────────────────────
  String get enrollConfirm     => _t('Confirm Enrollment',   'تأكيد التسجيل');
  String get payNow            => _t('Pay Now',               'ادفع الآن');
  String get free              => _t('Free',                  'مجاني');
  String get paymentMethod     => _t('Payment Method',        'طريقة الدفع');
  String get orderSummary      => _t('Order Summary',         'ملخص الطلب');
  String get enrolledSuccess   => _t('Successfully enrolled!','تم التسجيل بنجاح!');

  // ── Common ──────────────────────────────────────────────────
  String get loading           => _t('Loading...',            'جاري التحميل...');
  String get retry             => _t('Try Again',             'حاول مجدداً');
  String get cancel            => _t('Cancel',                'إلغاء');
  String get confirm           => _t('Confirm',               'تأكيد');
  String get save              => _t('Save',                  'حفظ');
  String get email             => _t('Email',                 'البريد الإلكتروني');
  String get name              => _t('Name',                  'الاسم');
  String get password          => _t('Password',              'كلمة المرور');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
