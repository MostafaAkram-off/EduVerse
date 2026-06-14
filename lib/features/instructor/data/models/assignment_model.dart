class AssignmentModel {
  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.sessionId,
    this.dueDate,
    this.submissionsCount = 0,
    this.gradedCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final String courseId;
  final String? sessionId;
  final DateTime? dueDate;
  final int submissionsCount;
  final int gradedCount;

  bool get fullyGraded => submissionsCount > 0 && gradedCount >= submissionsCount;
  int get pendingCount => (submissionsCount - gradedCount).clamp(0, submissionsCount);

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id:               json['id']?.toString() ?? '',
      title:            json['title']?.toString() ?? '',
      description:      json['description']?.toString() ?? '',
      courseId:         json['courseId']?.toString() ?? json['course_id']?.toString() ?? '',
      sessionId:        json['sessionId']?.toString() ?? json['session_id']?.toString(),
      dueDate:          DateTime.tryParse(json['dueDate']?.toString() ?? json['due_date']?.toString() ?? ''),
      submissionsCount: (json['submissionsCount'] ?? json['submissions_count'] ?? json['totalSubmissions'] ?? 0) as int,
      gradedCount:      (json['gradedCount'] ?? json['graded_count'] ?? 0) as int,
    );
  }
}
