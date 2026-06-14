import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/data/models/register_response.dart';
import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final RegisterRepository _repo;
  Future<RegisterResponse> call(RegisterRequest request) => _repo.register(request);
}
