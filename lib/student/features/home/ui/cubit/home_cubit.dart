import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/api/recommendations/recommendations_api_service.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final dio = GetIt.instance<Dio>();
      final recommendationsApi = GetIt.instance<RecommendationsApiService>();

      final results = await Future.wait([
        dio.get<dynamic>(ApiEndpoints.myEnrolledCourses),
        recommendationsApi.getForMe(),
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
        final progress = (item['progressPercent'] as num?)?.toInt() ??
            (item['progress'] as num?)?.toInt() ??
            (courseJson['progressPercent'] as num?)?.toInt() ??
            (courseJson['progress'] as num?)?.toInt() ?? 0;
        final model = CourseModel.fromJson(courseJson)
            .copyWith(progressPercent: progress, isEnrolled: true);
        if (model.id.isNotEmpty) enrolledCourses.add(model);
      }

      // Parse personalized recommendations from API
      final recRaw = results[1].data;
      final recList = recRaw is List
          ? recRaw
          : recRaw is Map
              ? ((recRaw['data'] ?? recRaw['courses'] ?? recRaw['recommendations'] ?? []) as List)
              : <dynamic>[];

      final recommendations = recList
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .where((c) => c.id.isNotEmpty)
          .take(10)
          .toList();

      final completedCount =
          enrolledCourses.where((c) => c.progressPercent >= 100).length;

      emit(HomeLoaded(
        enrolledCourses: enrolledCourses,
        upcomingSessions: const [],
        recommendedCourses: recommendations,
        completedCourses: completedCount,
        totalHours: totalHoursAccum.round(),
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data. Please try again.'));
    }
  }
}
