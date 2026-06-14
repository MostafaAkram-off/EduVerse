import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import '../../data/models/enrolled_course_model.dart';

part 'learning_state.dart';

class LearningCubit extends Cubit<LearningState> {
  LearningCubit(this._dio) : super(LearningInitial());

  final Dio _dio;

  Future<void> loadLearning() async {
    emit(LearningLoading());
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.myEnrolledCourses);
      final rawData = response.data;

      // API may return a plain list or an object with a data/items wrapper
      List<dynamic> list;
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        list = (rawData['data'] ?? rawData['items'] ?? rawData['courses'] ?? []) as List<dynamic>;
      } else {
        list = [];
      }

      final enrolled = list.map((e) {
        final item = e as Map<String, dynamic>;
        // Handle enrollment wrapper: { course: {...}, progressPercent: ... }
        final courseJson = (item['course'] as Map<String, dynamic>?) ?? item;
        final progress = (item['progressPercent'] as num?)?.toInt() ?? 0;
        final course = CourseModel.fromJson(courseJson).copyWith(
          isEnrolled: true,
          progressPercent: progress,
        );
        return EnrolledCourseModel(
          course: course,
          sessions: const [],
          assignments: const [],
          attendedSessions: 0,
          totalSessions: 0,
        );
      }).toList();

      final inProgress = enrolled.where((e) => e.course.progressPercent < 100).toList();
      final completed  = enrolled.where((e) => e.course.progressPercent == 100).toList();

      emit(LearningLoaded(
        inProgress: inProgress,
        completed: completed,
        activeTab: LearningTab.inProgress,
      ));
    } catch (e) {
      emit(LearningError('Failed to load your courses. Please try again.'));
    }
  }

  void switchTab(LearningTab tab) {
    if (state is LearningLoaded) {
      emit((state as LearningLoaded).copyWith(activeTab: tab));
    }
  }
}
