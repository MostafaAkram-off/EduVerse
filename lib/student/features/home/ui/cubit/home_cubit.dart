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
        dio.get<dynamic>(ApiEndpoints.myNotifications).catchError((_) => Response<dynamic>(requestOptions: RequestOptions(), statusCode: 200, data: [])),
        recommendationsApi.getTrending().catchError((_) => Response<dynamic>(requestOptions: RequestOptions(), statusCode: 200, data: [])),
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

      // my-enrolled-courses doesn't return progressPercent — fetch it per-course
      if (enrolledCourses.isNotEmpty) {
        final progressValues = await Future.wait(
          enrolledCourses.map((c) => _fetchProgress(dio, c.id)),
        );
        for (var i = 0; i < enrolledCourses.length; i++) {
          final pct = progressValues[i];
          if (pct > 0) {
            enrolledCourses[i] = enrolledCourses[i].copyWith(progressPercent: pct);
          }
        }
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

      // Count unread notifications (non-fatal)
      int unreadCount = 0;
      try {
        final notifRaw = results[2].data;
        final notifList = notifRaw is List
            ? notifRaw
            : notifRaw is Map
                ? ((notifRaw['data'] ?? notifRaw['notifications'] ?? []) as List)
                : <dynamic>[];
        unreadCount = notifList
            .where((n) => n is Map && n['isRead'] != true)
            .length;
      } catch (_) {}

      // Parse trending courses (non-fatal)
      final trendingCourses = <CourseModel>[];
      try {
        final trendRaw = results[3].data;
        final trendList = trendRaw is List
            ? trendRaw
            : trendRaw is Map
                ? ((trendRaw['data'] ?? trendRaw['courses'] ?? trendRaw['recommendations'] ?? []) as List)
                : <dynamic>[];
        trendingCourses.addAll(
          trendList
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .take(10),
        );
      } catch (_) {}

      emit(HomeLoaded(
        enrolledCourses: enrolledCourses,
        upcomingSessions: const [],
        recommendedCourses: recommendations,
        trendingCourses: trendingCourses,
        completedCourses: completedCount,
        totalHours: totalHoursAccum.round(),
        unreadNotifications: unreadCount,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data. Please try again.'));
    }
  }

  Future<int> _fetchProgress(Dio dio, String courseId) async {
    if (courseId.isEmpty) return 0;
    try {
      final resp = await dio.get<dynamic>(ApiEndpoints.progressCourse(courseId));
      final raw = resp.data;
      if (raw is! Map) return 0;
      final pct = (raw['progression'] ?? raw['progressPercent'] ??
                   raw['progress'] ?? raw['percent']) as num?;
      return pct?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
