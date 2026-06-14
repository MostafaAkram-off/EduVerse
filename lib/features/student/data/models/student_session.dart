enum StudentSessionStatus { upcoming, ongoing, completed }

class StudentSession {
  final String id;
  final String courseTitle;
  final String instructorName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOnline;
  final StudentSessionStatus status;
  final String? title;
  final int? sessionNumber;

  const StudentSession({
    required this.id,
    required this.courseTitle,
    required this.instructorName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isOnline,
    required this.status,
    this.title,
    this.sessionNumber,
  });

  factory StudentSession.fromJson(
    Map<String, dynamic> json, {
    String courseTitle = '',
    String instructorName = '',
  }) {
    final start = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
    final durationHours = (json['duration'] as num?)?.toDouble() ?? 1.0;
    final end = start.add(Duration(minutes: (durationHours * 60).round()));
    final now = DateTime.now();

    final StudentSessionStatus status;
    if (end.isBefore(now)) {
      status = StudentSessionStatus.completed;
    } else if (start.isBefore(now)) {
      status = StudentSessionStatus.ongoing;
    } else {
      status = StudentSessionStatus.upcoming;
    }

    final videoUrl = json['videoUrl']?.toString() ?? '';
    final externalLink = json['externalLink']?.toString() ?? '';
    final hasOnlineLink = videoUrl.isNotEmpty || externalLink.isNotEmpty;
    final location = json['location']?.toString().isNotEmpty == true
        ? json['location'] as String
        : hasOnlineLink
            ? 'Online'
            : 'On-site';

    return StudentSession(
      id:             json['id']?.toString() ?? '',
      courseTitle:    courseTitle,
      instructorName: instructorName,
      location:       location,
      startTime:      start,
      endTime:        end,
      isOnline:       hasOnlineLink || location.toLowerCase() == 'online',
      status:         status,
      title:          json['title'] as String?,
      sessionNumber:  json['sessionNumber'] as int?,
    );
  }

  String get statusLabel => switch (status) {
    StudentSessionStatus.upcoming  => 'Upcoming',
    StudentSessionStatus.ongoing   => 'Live',
    StudentSessionStatus.completed => 'Done',
  };
}
