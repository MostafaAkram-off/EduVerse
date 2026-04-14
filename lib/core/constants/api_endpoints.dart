/// REST paths — swap [baseUrl] via `--dart-define=API_BASE_URL=...` or update default.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.eduverse.example/v1',
  );

  // ── Auth ─────────────────────────────────────────────────
  static const String login              = '/auth/login';
  static const String register           = '/auth/register';
  static const String verifyEmail        = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String logout             = '/auth/logout';
  static const String refreshToken       = '/auth/refresh';
  static const String forgotPassword     = '/auth/forgot-password';
  static const String verifyOtp          = '/auth/verify-otp';
  static const String resetPassword      = '/auth/reset-password';

  // ── Profile ───────────────────────────────────────────────
  static const String profile       = '/profile';
  static const String updateProfile = '/profile';
  static const String uploadAvatar  = '/profile/avatar';

  // ── Courses ───────────────────────────────────────────────
  static const String courses = '/courses';
  static String courseDetail(int id) => '/courses/$id';

  // ── Enrollment & payments ─────────────────────────────────
  static const String enroll         = '/enrollments';
  static const String paymentHistory = '/payments';
  static String paymentReceipt(String id) => '/payments/$id/receipt';

  // ── Learning (student) ────────────────────────────────────
  static const String myCourses = '/me/courses';
  static String classroom(int courseId) => '/me/courses/$courseId/classroom';

  // ── Sessions ──────────────────────────────────────────────
  static const String sessions = '/sessions';
  static String sessionDetail(int id) => '/sessions/$id';

  // ── Assignments ───────────────────────────────────────────
  static const String assignments = '/assignments';
  static String submitAssignment(int id) => '/assignments/$id/submit';

  // ── Attendance ────────────────────────────────────────────
  static const String attendanceScan = '/attendance/scan';

  // ── Certificates ──────────────────────────────────────────
  static const String certificates = '/certificates';
  static String certificateDetail(String id) => '/certificates/$id';

  // ── Notifications ─────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';

  // ── Instructor ────────────────────────────────────────────
  static const String instructorStats    = '/instructor/stats';
  static const String instructorCourses  = '/instructor/courses';
  static const String instructorSessions = '/instructor/sessions';
  static const String instructorStudents = '/instructor/students';
  static const String createCourse       = '/instructor/courses';
}
