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

    // Try every common name field the API might return
    final firstName = json['firstName']?.toString() ?? json['first_name']?.toString() ?? '';
    final lastName  = json['lastName']?.toString()  ?? json['last_name']?.toString()  ?? '';
    final fullName  = (firstName.isNotEmpty && lastName.isNotEmpty)
        ? '$firstName $lastName'
        : (firstName.isNotEmpty ? firstName : lastName);
    final emailStr  = (json['email']        ?? json['studentEmail'] ??
                       json['userEmail']    ?? json['emailAddress'] ?? '')
                      .toString();
    String firstOf(List<String?> keys) {
      for (final k in keys) {
        final v = k?.trim();
        if (v != null && v.isNotEmpty) return v;
      }
      return '';
    }
    final name = firstOf([
      json['name']?.toString(),
      json['studentName']?.toString(),
      json['fullName']?.toString(),
      json['displayName']?.toString(),
      json['userName']?.toString(),
      fullName.isNotEmpty ? fullName : null,
      emailStr.contains('@') ? emailStr.split('@').first : emailStr,
    ]);

    // Grade may not come from students endpoint; treat missing/null as empty
    final rawGrade = json['grade'];
    final grade = rawGrade == null || rawGrade.toString().isEmpty
        ? ''
        : rawGrade is num
            ? rawGrade.toStringAsFixed(0)
            : rawGrade.toString();

    return StudentModel(
      id:              json['id']?.toString() ?? json['userId']?.toString() ?? '',
      name:            name,
      email:           emailStr,
      course:          json['course']?.toString() ??
                       json['courseName']?.toString() ??
                       json['courseTitle']?.toString() ?? '',
      progressPercent: toPercent(progressRaw),
      grade:           grade,
      attendance:      toPercent(attendanceRaw),
    );
  }
}
