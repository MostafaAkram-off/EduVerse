import 'package:dio/dio.dart';
import 'package:edu_verse/api/assignments/assignments_api_service.dart';
import 'package:edu_verse/api/attendance/attendance_api_service.dart';
import 'package:edu_verse/api/auth/auth_api_service.dart';
import 'package:edu_verse/api/certificates/certificates_api_service.dart';
import 'package:edu_verse/api/courses/courses_api_service.dart';
import 'package:edu_verse/api/enrollment/enrollment_api_service.dart';
import 'package:edu_verse/api/learning/learning_api_service.dart';
import 'package:edu_verse/api/notifications/notifications_api_service.dart';
import 'package:edu_verse/api/profile/profile_api_service.dart';
import 'package:edu_verse/api/sessions/sessions_api_service.dart';
import 'package:edu_verse/config/dio/dio_module.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

/// Call once from [main] before [runApp]. Token can be supplied after login.
void configureDependencies({String? accessToken}) {
  if (sl.isRegistered<AuthApiService>()) return;

  sl.registerLazySingleton<Dio>(() => DioModule.create(accessToken: accessToken));

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
    ..registerLazySingleton(() => ProfileApiService(sl()));
}
