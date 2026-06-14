import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';

class VerifyCodeUseCase {
  const VerifyCodeUseCase(this._repo);
  final ForgotPasswordRepository _repo;
  Future<void> call({required String email, required String code}) =>
      _repo.verifyCode(email: email, code: code);
}
