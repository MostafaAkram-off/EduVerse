class ApiEndpoints {
  ApiEndpoints._();

  // TODO: Update baseUrl when API is ready
  static const String baseUrl = 'https://api.eduverse.com/api/v1/';

  // Auth
  static const String login               = 'auth/login';
  static const String register            = 'auth/register';
  static const String verifyEmail         = 'auth/verify-email';
  static const String resendVerification  = 'auth/resend-verification';
  static const String forgotPassword      = 'auth/forgot-password';
  static const String verifyOtp           = 'auth/verify-otp';
  static const String resetPassword       = 'auth/reset-password';
  static const String logout              = 'auth/logout';
  static const String refreshToken        = 'auth/refresh-token';

  // Profile
  static const String profile             = 'profile';
  static const String updateProfile       = 'profile/update';
  static const String uploadAvatar        = 'profile/avatar';

  // Instructor
  static const String instructorStats     = 'instructor/stats';
  static const String instructorCourses   = 'instructor/courses';
  static const String instructorSessions  = 'instructor/sessions';
  static const String instructorStudents  = 'instructor/students';
  static const String createCourse        = 'instructor/courses/create';
  static const String updateCourse        = 'instructor/courses/{id}';
  static const String deleteCourse        = 'instructor/courses/{id}';
  static const String sessionDetail       = 'instructor/sessions/{id}';

  // Student
  static const String studentCourses      = 'student/courses';
  static const String studentSessions     = 'student/sessions';
  static const String studentProgress     = 'student/progress';
  static const String enrollments         = 'student/enrollments';
}
