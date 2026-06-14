class InstructorStats {
  const InstructorStats({
    required this.totalStudents,
    required this.activeCourses,
    required this.sessionsToday,
    required this.completionRate,
    this.studentsTrend,
    this.completionTrend,
  });

  final int totalStudents;
  final int activeCourses;
  final int sessionsToday;
  final double completionRate; // 0.0–1.0
  final String? studentsTrend;
  final String? completionTrend;

  factory InstructorStats.fromJson(Map<String, dynamic> json) {
    final rate = json['completionRate'] ?? json['completion_rate'] ?? 0;
    return InstructorStats(
      totalStudents:   (json['totalStudents']   ?? json['total_students']   ?? 0) as int,
      activeCourses:   (json['activeCourses']   ?? json['active_courses']   ?? 0) as int,
      sessionsToday:   (json['sessionsToday']   ?? json['sessions_today']   ?? 0) as int,
      completionRate:  (rate is int ? rate.toDouble() : (rate as num).toDouble()),
      studentsTrend:   json['studentsTrend']?.toString()  ?? json['students_trend']?.toString(),
      completionTrend: json['completionTrend']?.toString() ?? json['completion_trend']?.toString(),
    );
  }
}
