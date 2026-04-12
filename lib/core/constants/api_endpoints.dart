class ApiEndpoints {
  ApiEndpoints._();

  // TODO: Update baseUrl when API is ready
  static const String baseUrl = 'https://api.eduverse.com/api/v1/';

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String verifyEmail = 'auth/verify-email';
  static const String resendVerification = 'auth/resend-verification';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
}