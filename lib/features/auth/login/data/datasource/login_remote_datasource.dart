import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/data/models/login_response.dart';

abstract interface class LoginRemoteDatasource {
  Future<LoginResponse> login(LoginRequest request);
}
