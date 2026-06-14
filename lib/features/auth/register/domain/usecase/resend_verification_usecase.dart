import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';

class ResendVerificationUseCase {
  const ResendVerificationUseCase(this._repo);
  final RegisterRepository _repo;
  Future<void> call(String email) => _repo.resendVerification(email);
}
