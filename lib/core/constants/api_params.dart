/// Query / body field names — align with backend contract when available.
abstract final class ApiParams {
  ApiParams._();

  // Common query
  static const String page     = 'page';
  static const String limit    = 'limit';
  static const String search   = 'search';
  static const String category = 'category';
  static const String sort     = 'sort';

  // Auth body
  static const String email           = 'email';
  static const String password        = 'password';
  static const String confirmPassword = 'confirm_password';
  static const String name            = 'name';
  static const String phone           = 'phone';
  static const String role            = 'role';
  static const String code            = 'code';
  static const String newPassword     = 'new_password';
  static const String token           = 'token';
  static const String refreshToken    = 'refresh_token';

  // Response fields
  static const String success    = 'success';
  static const String message    = 'message';
  static const String data       = 'data';
  static const String user       = 'user';
  static const String id         = 'id';
  static const String statusCode = 'status_code';

  // Enrollment
  static const String courseId      = 'course_id';
  static const String paymentMethod = 'payment_method';

  // Attendance
  static const String qrPayload = 'code';
}
