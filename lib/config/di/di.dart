import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:edu_verse/api/assignments/assignments_api_service.dart';
import 'package:edu_verse/api/attendance/attendance_api_service.dart';
import 'package:edu_verse/api/auth/auth_api_service.dart';
import 'package:edu_verse/api/certificates/certificates_api_service.dart';
import 'package:edu_verse/api/courses/courses_api_service.dart';
import 'package:edu_verse/api/enrollment/enrollment_api_service.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/api/learning/learning_api_service.dart';
import 'package:edu_verse/api/notifications/notifications_api_service.dart';
import 'package:edu_verse/api/profile/profile_api_service.dart';
import 'package:edu_verse/api/recommendations/recommendations_api_service.dart';
import 'package:edu_verse/api/sessions/sessions_api_service.dart';
import 'package:edu_verse/config/dio/dio_module.dart';

// ── Auth — Login ───────────────────────────────────────────────────────────
import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource.dart';
import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/login/data/repository/login_repository_impl.dart';
import 'package:edu_verse/features/auth/login/domain/repository/login_repository.dart';
import 'package:edu_verse/features/auth/login/domain/usecase/login_usecase.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_cubit.dart';

// ── Auth — Register ────────────────────────────────────────────────────────
import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource.dart';
import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/register/data/repository/register_repository_impl.dart';
import 'package:edu_verse/features/auth/register/domain/repository/register_repository.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/register_usecase.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/verify_email_usecase.dart';
import 'package:edu_verse/features/auth/register/domain/usecase/resend_verification_usecase.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_cubit.dart';

// ── Auth — Forgot Password ─────────────────────────────────────────────────
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource.dart';
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource_impl.dart';
import 'package:edu_verse/features/auth/forgot_password/data/repository/forgot_password_repository_impl.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/repository/forgot_password_repository.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/forgot_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/verify_code_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/domain/usecase/reset_password_usecase.dart';
import 'package:edu_verse/features/auth/forgot_password/ui/cubit/forgot_password_cubit.dart';

// ── Instructor ─────────────────────────────────────────────────────────────
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/submissions_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/course_detail_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/session_detail_cubit.dart';

// ── Student ────────────────────────────────────────────────────────────────
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';

// ── Onboarding ─────────────────────────────────────────────────────────────
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_cubit.dart';

// ── Student Courses ────────────────────────────────────────────────────────
import 'package:edu_verse/student/features/courses/ui/cubit/courses_cubit.dart';

// ── Student Learning ───────────────────────────────────────────────────────
import 'package:edu_verse/student/features/learning/ui/cubit/learning_cubit.dart';

// ── Student Home ────────────────────────────────────────────────────────────
import 'package:edu_verse/student/features/home/ui/cubit/home_cubit.dart';

final sl = GetIt.instance;

/// Call once from [main] before [runApp].
void configureDependencies() {
  if (sl.isRegistered<AuthApiService>()) return;

  sl.registerLazySingleton<Dio>(() => DioModule.create());

  // ── Remote API services ──────────────────────────────────────────────────
  sl
    ..registerLazySingleton(() => AuthApiService(sl()))
    ..registerLazySingleton(() => CoursesApiService(sl()))
    ..registerLazySingleton(() => EnrollmentApiService(sl()))
    ..registerLazySingleton(() => LearningApiService(sl()))
    ..registerLazySingleton(() => SessionsApiService(sl()))
    ..registerLazySingleton(() => AssignmentsApiService(sl()))
    ..registerLazySingleton(() => AttendanceApiService(sl()))
    ..registerLazySingleton(() => CertificatesApiService(sl()))
    ..registerLazySingleton(() => NotificationsApiService(sl()))
    ..registerLazySingleton(() => ProfileApiService(sl()))
    ..registerLazySingleton(() => InstructorApiService(sl()))
    ..registerLazySingleton(() => RecommendationsApiService(sl()));

  // ── Login ────────────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<LoginRemoteDatasource>(
        () => LoginRemoteDatasourceImpl(sl()))
    ..registerLazySingleton<LoginRepository>(
        () => LoginRepositoryImpl(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerFactory(() => LoginCubit(sl()));

  // ── Register ─────────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<RegisterRemoteDatasource>(
        () => RegisterRemoteDatasourceImpl(sl()))
    ..registerLazySingleton<RegisterRepository>(
        () => RegisterRepositoryImpl(sl()))
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => VerifyEmailUseCase(sl()))
    ..registerLazySingleton(() => ResendVerificationUseCase(sl()))
    ..registerFactory(() => RegisterCubit(
          registerUseCase: sl(),
          verifyEmailUseCase: sl(),
          resendUseCase: sl(),
        ));

  // ── Forgot Password ───────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<ForgotPasswordRemoteDatasource>(
        () => ForgotPasswordRemoteDatasourceImpl(sl()))
    ..registerLazySingleton<ForgotPasswordRepository>(
        () => ForgotPasswordRepositoryImpl(sl()))
    ..registerLazySingleton(() => ForgotPasswordUseCase(sl()))
    ..registerLazySingleton(() => VerifyCodeUseCase(sl()))
    ..registerLazySingleton(() => ResetPasswordUseCase(sl()))
    ..registerFactory(() => ForgotPasswordCubit(
          forgotPasswordUseCase: sl(),
          verifyCodeUseCase: sl(),
          resetPasswordUseCase: sl(),
        ));

  // ── Instructor ────────────────────────────────────────────────────────────
  sl.registerFactory(() => InstructorCubit(sl()));
  sl.registerFactory(() => InstructorSubmissionsCubit(sl()));
  sl.registerFactory(() => InstructorCourseDetailCubit(sl(), sl()));
  sl.registerFactory(() => InstructorSessionDetailCubit(sl(), sl()));

  // ── Student ───────────────────────────────────────────────────────────────
  sl.registerFactory(() => StudentCubit());

  // ── Onboarding ────────────────────────────────────────────────────────────
  sl.registerFactory(() => OnboardingCubit());

  // ── Student Courses ────────────────────────────────────────────────────────
  sl.registerFactory(() => CoursesCubit(sl()));

  // ── Student Home (singleton so PaymentReceiptScreen can trigger a refresh) ──
  sl.registerLazySingleton(() => HomeCubit());

  // ── Student Learning (singleton so enrollment refresh propagates) ───────────
  sl.registerLazySingleton(() => LearningCubit(sl()));
}
