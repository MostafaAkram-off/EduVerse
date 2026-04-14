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
}
