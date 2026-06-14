import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/data/models/register_response.dart';

abstract interface class RegisterRemoteDatasource {
  /// Step 1 — sends the OTP to the user's email.
  Future<RegisterResponse> register(RegisterRequest request);

  /// Step 2 — submits all fields + OTP to complete account creation.
  Future<void> verifyEmail({required RegisterRequest request, required String code});

  /// Resend OTP to the same email.
  Future<void> resendVerification(String email);
}
