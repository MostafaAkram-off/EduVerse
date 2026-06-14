import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repo);
  final ForgotPasswordRepository _repo;
  Future<void> call(String email) => _repo.sendResetCode(email);
}
