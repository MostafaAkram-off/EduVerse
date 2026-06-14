import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';

sealed class StudentState {
  const StudentState();
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentLoaded extends StudentState {
  final List<EnrolledCourse> courses;
  final List<StudentSession> sessions;      // upcoming + ongoing
  final List<StudentSession> pastSessions;  // completed
  final int totalSessionsCount;             // sum across all courses

  const StudentLoaded({
    required this.courses,
    required this.sessions,
    this.pastSessions = const [],
    this.totalSessionsCount = 0,
  });
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);
}
