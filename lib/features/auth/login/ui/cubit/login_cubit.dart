import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/domain/usecase/login_usecase.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_state.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase) : super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
    try {
      final response = await _loginUseCase(
        LoginRequest(email: email, password: password),
      );
      AuthSession.set(
        response.user,
        token: response.token,
        refreshToken: response.refreshToken,
      );
      await AppPreferences.instance.saveSession(
        token: response.token,
        refreshToken: response.refreshToken,
        role: response.user.role.value,
        userId: response.user.id,
        name: response.user.name.isNotEmpty
            ? response.user.name
            : response.user.fullName,
        email: response.user.email,
        phone: response.user.phone,
      );
      emit(LoginSuccess(user: response.user, role: response.user.role));
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() => emit(const LoginInitial());
}
