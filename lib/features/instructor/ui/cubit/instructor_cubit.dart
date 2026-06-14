import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/api/courses/courses_api_service.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/features/instructor/data/models/course_model.dart';
import 'package:edu_verse/features/instructor/data/models/instructor_stats.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/data/models/student_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorCubit extends Cubit<InstructorState> {
  InstructorCubit(this._api, this._coursesApi) : super(const InstructorInitial());

  final InstructorApiService _api;
  final CoursesApiService _coursesApi;

  Future<void> loadData() async {
    emit(const InstructorLoading());
    try {
      final results = await Future.wait([
        _api.getOverview(),
        _api.getSessions(),
        _api.getStudents(),
        _coursesApi.getAllCourses(),
      ]);

      // Parse stats — unwrap optional 'data' envelope
      final overviewRaw = results[0].data;
      final Map<String, dynamic> statsMap;
      if (overviewRaw is Map<String, dynamic>) {
        statsMap = (overviewRaw['data'] as Map<String, dynamic>?) ?? overviewRaw;
      } else {
        statsMap = {};
      }
      final apiStats = InstructorStats.fromJson(statsMap);

      // Parse sessions → split into today / upcoming
      final sessionsRaw = results[1].data;
      final sessionsList = sessionsRaw is List
          ? sessionsRaw
          : sessionsRaw is Map
              ? ((sessionsRaw['data'] ?? sessionsRaw['sessions'] ?? []) as List)
              : <dynamic>[];
      final now = DateTime.now();
      final today    = <SessionModel>[];
      final upcoming = <SessionModel>[];
      for (final s in sessionsList) {
        final session = SessionModel.fromJson(s as Map<String, dynamic>);
        final d = session.startTime;
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          today.add(session);
        } else if (d.isAfter(now)) {
          upcoming.add(session);
        }
      }
      today.sort((a, b) => a.startTime.compareTo(b.startTime));
      upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Parse students
      final studentsRaw = results[2].data;
      final studentsList = studentsRaw is List
          ? studentsRaw
          : studentsRaw is Map
              ? ((studentsRaw['data'] ?? studentsRaw['students'] ?? []) as List)
              : <dynamic>[];
      final students = studentsList
          .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
          .toList();

      // Parse courses
      final coursesRaw = results[3].data;
      final coursesList = coursesRaw is List
          ? coursesRaw
          : coursesRaw is Map
              ? ((coursesRaw['data'] ?? coursesRaw['courses'] ?? []) as List)
              : <dynamic>[];
      final courses = coursesList
          .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
          .toList();

      // Prefer computed values from real data; fall back to API overview
      final activeCourses = courses
          .where((c) => c.status == CourseStatus.active)
          .length;
      final stats = InstructorStats(
        totalStudents:   students.isNotEmpty ? students.length   : apiStats.totalStudents,
        activeCourses:   courses.isNotEmpty  ? activeCourses     : apiStats.activeCourses,
        sessionsToday:   today.isNotEmpty    ? today.length      : apiStats.sessionsToday,
        completionRate:  apiStats.completionRate,
        studentsTrend:   apiStats.studentsTrend,
        completionTrend: apiStats.completionTrend,
      );

      emit(InstructorLoaded(
        stats:            stats,
        courses:          courses,
        todaySessions:    today,
        upcomingSessions: upcoming,
        students:         students,
      ));
    } catch (_) {
      emit(const InstructorError('Failed to load data. Please try again.'));
    }
  }

  void refresh() => loadData();
}
