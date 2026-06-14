import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';

class VerifyEmailUseCase {
  const VerifyEmailUseCase(this._repo);
  final RegisterRepository _repo;
  Future<void> call({required RegisterRequest request, required String code}) =>
      _repo.verifyEmail(request: request, code: code);
}
