import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/api/courses/courses_api_service.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/features/instructor/data/models/assignment_model.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/course_detail_state.dart';

class InstructorCourseDetailCubit extends Cubit<InstructorCourseDetailState> {
  InstructorCourseDetailCubit(this._coursesApi, this._instructorApi)
      : super(const InstructorCourseDetailInitial());

  final CoursesApiService _coursesApi;
  final InstructorApiService _instructorApi;

  String? _currentCourseId;

  Future<void> loadCourseDetail(String courseId) async {
    _currentCourseId = courseId;
    emit(const InstructorCourseDetailLoading());
    try {
      final results = await Future.wait([
        _coursesApi.getAllSessions(courseId),
        _coursesApi.getAllAssignments(courseId),
      ]);

      List<dynamic> parseList(dynamic raw, List<String> keys) {
        if (raw is List) return raw;
        if (raw is Map) {
          for (final k in keys) {
            if (raw[k] is List) return raw[k] as List;
          }
        }
        return [];
      }

      final sessions = parseList(results[0].data, ['data', 'sessions'])
          .map((s) => SessionModel.fromJson(s as Map<String, dynamic>))
          .toList();
      final assignments = parseList(results[1].data, ['data', 'assignments'])
          .map((a) => AssignmentModel.fromJson(a as Map<String, dynamic>))
          .toList();

      emit(InstructorCourseDetailLoaded(sessions: sessions, assignments: assignments));
    } catch (e) {
      emit(InstructorCourseDetailError(e.toString()));
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    final current = state;
    if (current is! InstructorCourseDetailLoaded) return false;
    // Optimistic remove
    emit(current.copyWith(
      sessions: current.sessions.where((s) => s.id != sessionId).toList(),
    ));
    try {
      await _instructorApi.deleteSession(sessionId);
      return true;
    } catch (_) {
      // Rollback on failure
      if (_currentCourseId != null) loadCourseDetail(_currentCourseId!);
      return false;
    }
  }

  Future<bool> deleteAssignment(String assignmentId) async {
    final current = state;
    if (current is! InstructorCourseDetailLoaded) return false;
    emit(current.copyWith(
      assignments: current.assignments.where((a) => a.id != assignmentId).toList(),
    ));
    try {
      await _instructorApi.deleteAssignment(assignmentId);
      return true;
    } catch (_) {
      if (_currentCourseId != null) loadCourseDetail(_currentCourseId!);
      return false;
    }
  }
}
