enum SessionStatus { upcoming, ongoing, completed }

class SessionModel {
  const SessionModel({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.startTime,
    required this.endTime,
    required this.studentsEnrolled,
    required this.location,
    required this.isOnline,
    required this.status,
  });

  final String id;
  final String courseId;
  final String courseTitle;
  final DateTime startTime;
  final DateTime endTime;
  final int studentsEnrolled;
  final String location;
  final bool isOnline;
  final SessionStatus status;

  String get statusLabel => switch (status) {
        SessionStatus.upcoming  => 'Upcoming',
        SessionStatus.ongoing   => 'Live Now',
        SessionStatus.completed => 'Completed',
      };
}
