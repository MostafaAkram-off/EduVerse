import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/data/models/login_response.dart';
import 'package:edu_verse/features/auth/login/domain/repository/login_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);
  final LoginRepository _repo;
  Future<LoginResponse> call(LoginRequest request) => _repo.login(request);
}
