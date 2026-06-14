import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repo);
  final ForgotPasswordRepository _repo;
  Future<void> call({required String email, required String code, required String newPassword}) =>
      _repo.resetPassword(email: email, code: code, newPassword: newPassword);
}
