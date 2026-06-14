import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource.dart';
import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/data/models/register_response.dart';
import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  const RegisterRepositoryImpl(this._ds);
  final RegisterRemoteDatasource _ds;
  @override
  Future<RegisterResponse> register(RegisterRequest request) => _ds.register(request);
  @override
  Future<void> verifyEmail({required RegisterRequest request, required String code}) =>
      _ds.verifyEmail(request: request, code: code);
  @override
  Future<void> resendVerification(String email) => _ds.resendVerification(email);
}
