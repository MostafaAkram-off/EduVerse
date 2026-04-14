import 'package:edu_verse/features/instructor/data/models/course_model.dart';
import 'package:edu_verse/features/instructor/data/models/instructor_stats.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/data/models/student_model.dart';

abstract class InstructorState {
  const InstructorState();
}

class InstructorInitial extends InstructorState {
  const InstructorInitial();
}

class InstructorLoading extends InstructorState {
  const InstructorLoading();
}

class InstructorLoaded extends InstructorState {
  const InstructorLoaded({
    required this.stats,
    required this.courses,
    required this.todaySessions,
    required this.upcomingSessions,
    required this.students,
  });

  final InstructorStats stats;
  final List<CourseModel> courses;
  final List<SessionModel> todaySessions;
  final List<SessionModel> upcomingSessions;
  final List<StudentModel> students;
}

class InstructorError extends InstructorState {
  const InstructorError(this.message);
  final String message;
}
