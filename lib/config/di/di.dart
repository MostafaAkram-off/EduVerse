import 'package:get_it/get_it.dart';
import 'package:edu_verse/config/dio/dio_module.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Networking ─────────────────────────────────────────
  sl.registerLazySingleton(() => DioModule.createDio());

  // ── Instructor ─────────────────────────────────────────
  sl.registerFactory(() => InstructorCubit());
}
