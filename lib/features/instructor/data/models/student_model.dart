class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.progressPercent,
    required this.grade,
    required this.attendance,
  });

  final String id;
  final String name;
  final String email;
  final String course;
  final int progressPercent; // 0–100
  final String grade;        // e.g. 'A', 'B+'
  final int attendance;      // 0–100 %

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final progressRaw   = json['progressPercent'] ?? json['progress_percent'] ?? json['progress'] ?? 0;
    final attendanceRaw = json['attendance'] ?? json['attendancePercent'] ?? json['attendance_percent'] ?? 0;

    int toPercent(dynamic raw) {
      if (raw is double && raw <= 1.0) return (raw * 100).round();
      return (raw as num).toInt();
    }

    return StudentModel(
      id:              json['id']?.toString() ?? '',
      name:            json['name']?.toString() ?? json['userName']?.toString() ?? '',
      email:           json['email']?.toString() ?? '',
      course:          json['course']?.toString() ??
                       json['courseName']?.toString() ??
                       json['courseTitle']?.toString() ?? '',
      progressPercent: toPercent(progressRaw),
      grade:           json['grade']?.toString() ?? 'N/A',
      attendance:      toPercent(attendanceRaw),
    );
  }
}
