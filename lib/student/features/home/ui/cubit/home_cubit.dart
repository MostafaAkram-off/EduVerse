import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final dio = GetIt.instance<Dio>();

      final results = await Future.wait([
        dio.get<dynamic>(ApiEndpoints.myEnrolledCourses),
        dio.get<dynamic>(ApiEndpoints.getAllCourses),
      ]);

      // Parse enrolled courses
      final enrolledRaw = results[0].data;
      final enrolledList = enrolledRaw is List
          ? enrolledRaw
          : enrolledRaw is Map
              ? ((enrolledRaw['data'] ?? enrolledRaw['courses'] ?? []) as List)
              : <dynamic>[];

      double totalHoursAccum = 0;
      final enrolledCourses = <CourseModel>[];
      for (final e in enrolledList) {
        final item = e as Map<String, dynamic>;
        final courseJson = (item['course'] as Map<String, dynamic>?) ?? item;
        totalHoursAccum += (courseJson['duration'] as num?)?.toDouble() ?? 0;
        final model = CourseModel.fromJson(courseJson);
        if (model.id.isNotEmpty) enrolledCourses.add(model);
      }

      // Parse all courses for recommendations (exclude enrolled ones)
      final allRaw = results[1].data;
      final allList = allRaw is List
          ? allRaw
          : allRaw is Map
              ? ((allRaw['data'] ?? allRaw['courses'] ?? []) as List)
              : <dynamic>[];

      final enrolledIds = enrolledCourses.map((c) => c.id).toSet();
      final recommendations = allList
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .where((c) => c.id.isNotEmpty && !enrolledIds.contains(c.id))
          .take(10)
          .toList();

      emit(HomeLoaded(
        enrolledCourses: enrolledCourses,
        upcomingSessions: const [],
        recommendedCourses: recommendations,
        completedCourses: 0,
        totalHours: totalHoursAccum.round(),
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data. Please try again.'));
    }
  }
}
