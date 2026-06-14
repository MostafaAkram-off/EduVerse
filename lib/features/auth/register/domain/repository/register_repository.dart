import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/data/models/register_response.dart';

abstract interface class RegisterRepository {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<void> verifyEmail({required RegisterRequest request, required String code});
  Future<void> resendVerification(String email);
}
