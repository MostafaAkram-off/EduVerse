import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  const ForgotPasswordRepositoryImpl(this._ds);
  final ForgotPasswordRemoteDatasource _ds;

  @override
  Future<void> sendResetCode(String email) => _ds.sendResetCode(email);

  @override
  Future<void> verifyCode({required String email, required String code}) =>
      _ds.verifyCode(email: email, code: code);

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _ds.resetPassword(email: email, code: code, newPassword: newPassword);
}
