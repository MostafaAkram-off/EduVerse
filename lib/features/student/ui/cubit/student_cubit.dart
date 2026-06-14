import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';
import 'package:edu_verse/features/student/ui/cubit/student_state.dart';

const _gradientPalette = [
  [Color(0xFF4A6CF7), Color(0xFF7C3AED)],
  [Color(0xFF22C55E), Color(0xFF059669)],
  [Color(0xFF7C3AED), Color(0xFFEC4899)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFF0EA5E9), Color(0xFF0369A1)],
  [Color(0xFFEF4444), Color(0xFFEC4899)],
];

List<Color> _gradientFor(int index) =>
    _gradientPalette[index % _gradientPalette.length];

class StudentCubit extends Cubit<StudentState> {
  StudentCubit() : super(const StudentInitial());

  Future<void> loadData() async {
    emit(const StudentLoading());
    try {
      final dio = GetIt.instance<Dio>();

      // 1. Fetch enrolled courses
      final enrolledRes = await dio.get<dynamic>(ApiEndpoints.myEnrolledCourses);
      final enrolledRaw = enrolledRes.data;
      final enrolledList = enrolledRaw is List
          ? enrolledRaw
          : enrolledRaw is Map
              ? ((enrolledRaw['data'] ?? enrolledRaw['courses'] ?? []) as List)
              : <dynamic>[];

      final courses = <EnrolledCourse>[];
      final allSessions = <StudentSession>[];
      final allPastSessions = <StudentSession>[];
      int totalSessionsCount = 0;

      // 2. Fetch sessions for each course in parallel
      await Future.wait(List.generate(enrolledList.length, (i) async {
        final item = enrolledList[i] as Map<String, dynamic>;
        final courseJson = (item['course'] as Map<String, dynamic>?) ?? item;
        final courseId = courseJson['id']?.toString() ?? '';
        if (courseId.isEmpty) return;

        final courseTitle = courseJson['title']?.toString() ?? '';
        final instructorName = courseJson['instructorName']?.toString() ??
            courseJson['instructor']?.toString() ??
            '';
        final category = courseJson['category']?.toString() ??
            courseJson['categoryName']?.toString() ??
            'Course';

        List<dynamic> sessionsRaw = [];
        try {
          final sessRes = await dio.get<dynamic>(ApiEndpoints.getAllSessions(courseId));
          final sessData = sessRes.data;
          sessionsRaw = sessData is List
              ? sessData
              : sessData is Map
                  ? ((sessData['data'] ?? sessData['sessions'] ?? []) as List)
                  : <dynamic>[];
        } catch (_) {}

        final totalSessions = sessionsRaw.length;
        totalSessionsCount += totalSessions;
        final now = DateTime.now();

        // Parse all sessions, split into upcoming/ongoing and completed
        final allCourseSessions = sessionsRaw
            .map((s) => StudentSession.fromJson(
                  s as Map<String, dynamic>,
                  courseTitle: courseTitle,
                  instructorName: instructorName,
                ))
            .toList();

        final courseUpcoming = allCourseSessions
            .where((s) => s.status != StudentSessionStatus.completed)
            .toList();
        final courseCompleted = allCourseSessions
            .where((s) => s.status == StudentSessionStatus.completed)
            .toList();

        allSessions.addAll(courseUpcoming);
        allPastSessions.addAll(courseCompleted);

        // Count completed sessions (date in the past) for progress
        int completedCount = 0;
        for (final s in sessionsRaw) {
          final raw = (s as Map<String, dynamic>)['date']?.toString() ?? '';
          final date = DateTime.tryParse(raw);
          if (date != null && date.isBefore(now)) completedCount++;
        }

        final progressPercent =
            totalSessions > 0 ? (completedCount / totalSessions).clamp(0.0, 1.0) : 0.0;

        // Find next upcoming session for this course
        final upcoming = courseUpcoming
            .where((s) => s.startTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        String? nextSessionDate;
        if (upcoming.isNotEmpty) {
          final dt = upcoming.first.startTime;
          const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
          final diff = dt.difference(DateTime(now.year, now.month, now.day)).inDays;
          final timeStr = _fmt12(dt);
          if (diff == 0) {
            nextSessionDate = 'Today, $timeStr';
          } else if (diff == 1) {
            nextSessionDate = 'Tomorrow, $timeStr';
          } else {
            nextSessionDate = '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, $timeStr';
          }
        }

        courses.add(EnrolledCourse(
          id: courseId,
          title: courseTitle,
          instructorName: instructorName,
          category: category,
          totalSessions: totalSessions,
          completedSessions: completedCount,
          progressPercent: progressPercent,
          gradientColors: _gradientFor(i),
          nextSessionDate: nextSessionDate,
        ));
      }));

      // Sort sessions by start time
      allSessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      allPastSessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // newest first

      emit(StudentLoaded(
        courses: courses,
        sessions: allSessions,
        pastSessions: allPastSessions,
        totalSessionsCount: totalSessionsCount,
      ));
    } catch (e) {
      emit(StudentError('Failed to load data. Please try again.'));
    }
  }

  void refresh() => loadData();
}

String _fmt12(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  final period = h >= 12 ? 'PM' : 'AM';
  final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '$hour12:$m $period';
}
