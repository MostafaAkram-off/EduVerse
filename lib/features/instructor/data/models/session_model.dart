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

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final startRaw = json['startTime'] ?? json['start_time'] ?? json['date'] ?? '';
    final endRaw   = json['endTime']   ?? json['end_time']   ?? '';
    final start = DateTime.tryParse(startRaw.toString()) ?? DateTime.now();
    final end   = DateTime.tryParse(endRaw.toString()) ??
        start.add(const Duration(hours: 1, minutes: 30));

    final now = DateTime.now();
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? '';
    final SessionStatus status;
    if (statusStr == 'ongoing' || statusStr == 'live') {
      status = SessionStatus.ongoing;
    } else if (statusStr == 'completed' || statusStr == 'done' || end.isBefore(now)) {
      status = SessionStatus.completed;
    } else {
      status = SessionStatus.upcoming;
    }

    final isOnline = (json['isOnline'] ?? json['is_online'] ?? json['online'] ?? false) as bool;

    return SessionModel(
      id:               json['id']?.toString() ?? '',
      courseId:         json['courseId']?.toString() ?? json['course_id']?.toString() ?? '',
      courseTitle:      json['courseTitle']?.toString() ??
                        json['course_title']?.toString() ??
                        json['title']?.toString() ?? '',
      startTime:        start,
      endTime:          end,
      studentsEnrolled: (json['studentsEnrolled'] ?? json['students_enrolled'] ??
                         json['studentsCount'] ?? 0) as int,
      location:         json['location']?.toString() ?? (isOnline ? 'Online' : 'Offline'),
      isOnline:         isOnline,
      status:           status,
    );
  }
}
