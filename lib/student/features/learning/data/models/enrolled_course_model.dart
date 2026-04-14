import '../../../courses/data/models/course_model.dart';

class SessionModel {
  final int id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final String status; // 'upcoming' | 'live' | 'completed'
  final bool isAttended;

  const SessionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    this.isAttended = false,
  });
}

class AssignmentModel {
  final int id;
  final String title;
  final String dueDate;
  final String status; // 'pending' | 'submitted' | 'graded'
  final int? grade;
  final int maxPoints;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    this.grade,
    required this.maxPoints,
  });
}

class EnrolledCourseModel {
  final CourseModel course;
  final List<SessionModel> sessions;
  final List<AssignmentModel> assignments;
  final int attendedSessions;
  final int totalSessions;

  const EnrolledCourseModel({
    required this.course,
    required this.sessions,
    required this.assignments,
    required this.attendedSessions,
    required this.totalSessions,
  });

  double get attendancePercent =>
      totalSessions == 0 ? 0 : (attendedSessions / totalSessions) * 100;
}