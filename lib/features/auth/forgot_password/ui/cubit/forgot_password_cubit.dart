import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/forgot_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/verify_code_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/reset_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyCodeUseCase verifyCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _forgot = forgotPasswordUseCase,
        _verify = verifyCodeUseCase,
        _reset = resetPasswordUseCase,
        super(const ForgotPasswordInitial());

  final ForgotPasswordUseCase _forgot;
  final VerifyCodeUseCase _verify;
  final ResetPasswordUseCase _reset;

  Future<void> sendCode(String email) async {
    emit(const ForgotPasswordLoading());
    try {
      await _forgot(email);
      emit(ForgotPasswordCodeSent(email));
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyCode({required String email, required String code}) async {
    emit(const ForgotPasswordLoading());
    try {
      await _verify(email: email, code: code);
      emit(ForgotPasswordCodeVerified(email: email, code: code));
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    emit(const ForgotPasswordLoading());
    try {
      await _reset(email: email, code: code, newPassword: newPassword);
      emit(const ForgotPasswordReset());
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() => emit(const ForgotPasswordInitial());
}
