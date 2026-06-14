import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/features/instructor/data/models/submission_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/submissions_state.dart';

class InstructorSubmissionsCubit extends Cubit<InstructorSubmissionsState> {
  InstructorSubmissionsCubit(this._api) : super(const InstructorSubmissionsInitial());

  final InstructorApiService _api;

  Future<void> loadSubmissions() async {
    emit(const InstructorSubmissionsLoading());
    try {
      final res = await _api.getSubmissions();
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['submissions'] ?? []) as List)
              : <dynamic>[];
      final submissions = list
          .map((s) => SubmissionModel.fromJson(s as Map<String, dynamic>))
          .toList();
      emit(InstructorSubmissionsLoaded(submissions: submissions));
    } catch (_) {
      emit(const InstructorSubmissionsError('Failed to load submissions.'));
    }
  }

  Future<void> gradeSubmission({
    required String assignmentId,
    required String studentId,
    required double grade,
    String? feedback,
  }) async {
    final current = state;
    if (current is! InstructorSubmissionsLoaded) return;
    emit(current.copyWith(isGrading: true));
    try {
      await _api.gradeSubmission(assignmentId, studentId, {
        'grade': grade,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      });
      final gradeStr = grade.toStringAsFixed(0);
      final updated = current.submissions.map((s) {
        if (s.assignmentId == assignmentId && s.studentId == studentId) {
          return s.copyWith(grade: gradeStr, feedback: feedback, isGraded: true);
        }
        return s;
      }).toList();
      emit(InstructorSubmissionsLoaded(submissions: updated));
    } catch (_) {
      emit(current.copyWith(isGrading: false));
    }
  }
}
