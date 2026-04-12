import 'package:get_it/get_it.dart';
import 'package:edu_verse/api/auth/auth_api_service.dart';
import 'package:edu_verse/config/dio/dio_module.dart';

// ── Login ─────────────────────────────────────────────────────
import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource.dart';
import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/login/data/repository/login_repository_impl.dart';
import 'package:edu_verse/features/auth/login/domain/repository/login_repository.dart';
import 'package:edu_verse/features/auth/login/domain/usecase/login_usecase.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_cubit.dart';

// ── Register ──────────────────────────────────────────────────
import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource.dart';
import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/register/data/repository/register_repository_impl.dart';
import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/register_usecase.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/verify_email_usecase.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_cubit.dart';

// ── Forgot Password ───────────────────────────────────────────
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource.dart';
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/forgot_password/data/repository/forgot_password_repository_impl.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/forgot_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/reset_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/verify_code_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/cubit/forgot_password_cubit.dart';

// ── Onboarding ────────────────────────────────────────────────
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Networking ────────────────────────────────────────────────
  sl.registerLazySingleton(() => DioModule.createDio());
  sl.registerLazySingleton(() => AuthApiService(sl()));

  // ── Login ─────────────────────────────────────────────────────
  sl.registerLazySingleton<LoginRemoteDatasource>(
      () => LoginRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerFactory(() => LoginCubit(sl()));

  // ── Register ──────────────────────────────────────────────────
  sl.registerLazySingleton<RegisterRemoteDatasource>(
      () => RegisterRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<RegisterRepository>(
      () => RegisterRepositoryImpl(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationUseCase(sl()));
  sl.registerFactory(() => RegisterCubit(
        registerUseCase: sl(),
        verifyEmailUseCase: sl(),
        resendUseCase: sl(),
      ));

  // ── Forgot Password ───────────────────────────────────────────
  sl.registerLazySingleton<ForgotPasswordRemoteDatasource>(
      () => ForgotPasswordRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<ForgotPasswordRepository>(
      () => ForgotPasswordRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerFactory(() => ForgotPasswordCubit(
        forgotPasswordUseCase: sl(),
        verifyCodeUseCase: sl(),
        resetPasswordUseCase: sl(),
      ));

  // ── Onboarding ────────────────────────────────────────────────
  sl.registerFactory(() => OnboardingCubit());
}
