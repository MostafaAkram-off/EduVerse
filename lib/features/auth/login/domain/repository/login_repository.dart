import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/data/models/login_response.dart';

abstract interface class LoginRepository {
  Future<LoginResponse> login(LoginRequest request);
}
