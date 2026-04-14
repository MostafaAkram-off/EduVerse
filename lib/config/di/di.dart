import 'package:get_it/get_it.dart';
import 'package:edu_verse/api/auth/auth_api_service.dart';
import 'package:edu_verse/config/dio/dio_module.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Networking ─────────────────────────────────────────────
  sl.registerLazySingleton(() => DioModule.createDio());
  sl.registerLazySingleton(() => AuthApiService(sl()));

  // ── Instructor ─────────────────────────────────────────────
  // Auth, register, forgot-password, onboarding cubits/repos will be
  // registered here once their branches are merged into dev.
  sl.registerFactory(() => InstructorCubit());
}
