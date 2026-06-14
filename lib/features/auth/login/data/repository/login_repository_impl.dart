import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource.dart';
import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/data/models/login_response.dart';
import 'package:edu_verse/features/auth/login/domain/repository/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  const LoginRepositoryImpl(this._ds);
  final LoginRemoteDatasource _ds;
  @override
  Future<LoginResponse> login(LoginRequest request) => _ds.login(request);
}
