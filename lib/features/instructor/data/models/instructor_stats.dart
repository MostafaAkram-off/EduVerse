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
  final String? studentsTrend;   // e.g. '+12%'
  final String? completionTrend; // e.g. '+5%'
}
