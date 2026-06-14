abstract interface class ForgotPasswordRepository {
  Future<void> sendResetCode(String email);
  Future<void> verifyCode({required String email, required String code});
  Future<void> resetPassword({required String email, required String code, required String newPassword});
}
