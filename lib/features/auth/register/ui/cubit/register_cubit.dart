import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/register_usecase.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/verify_email_usecase.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/resend_verification_usecase.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required RegisterUseCase registerUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required ResendVerificationUseCase resendUseCase,
  })  : _register = registerUseCase,
        _verify = verifyEmailUseCase,
        _resend = resendUseCase,
        super(const RegisterInitial());

  final RegisterUseCase _register;
  final VerifyEmailUseCase _verify;
  final ResendVerificationUseCase _resend;

  Future<void> register(RegisterRequest request) async {
    emit(const RegisterLoading());
    try {
      final res = await _register(request);
      emit(RegisterSuccess(res.email ?? request.email));
    } catch (e) {
      emit(RegisterError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyEmail({required RegisterRequest request, required String code}) async {
    emit(const RegisterVerifying());
    try {
      await _verify(request: request, code: code);
      emit(const RegisterVerified());
    } catch (e) {
      emit(RegisterError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resendVerification(String email) async {
    emit(const RegisterResending());
    try {
      await _resend(email);
      emit(RegisterSuccess(email));
    } catch (e) {
      emit(RegisterError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() => emit(const RegisterInitial());
}
