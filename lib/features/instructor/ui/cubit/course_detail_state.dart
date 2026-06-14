import 'package:edu_verse/features/instructor/data/models/assignment_model.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';

abstract class InstructorCourseDetailState {
  const InstructorCourseDetailState();
}

class InstructorCourseDetailInitial extends InstructorCourseDetailState {
  const InstructorCourseDetailInitial();
}

class InstructorCourseDetailLoading extends InstructorCourseDetailState {
  const InstructorCourseDetailLoading();
}

class InstructorCourseDetailLoaded extends InstructorCourseDetailState {
  const InstructorCourseDetailLoaded({
    required this.sessions,
    required this.assignments,
  });

  final List<SessionModel> sessions;
  final List<AssignmentModel> assignments;

  InstructorCourseDetailLoaded copyWith({
    List<SessionModel>? sessions,
    List<AssignmentModel>? assignments,
  }) =>
      InstructorCourseDetailLoaded(
        sessions: sessions ?? this.sessions,
        assignments: assignments ?? this.assignments,
      );
}

class InstructorCourseDetailError extends InstructorCourseDetailState {
  const InstructorCourseDetailError(this.message);
  final String message;
}
