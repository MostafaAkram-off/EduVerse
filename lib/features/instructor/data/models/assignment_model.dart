import 'package:edu_verse/core/constants/api_endpoints.dart';

class AssignmentModel {
  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.sessionId,
    this.dueDate,
    this.fileUrl,
    this.submissionsCount = 0,
    this.gradedCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final String courseId;
  final String? sessionId;
  final DateTime? dueDate;
  final String? fileUrl;
  final int submissionsCount;
  final int gradedCount;

  bool get fullyGraded => submissionsCount > 0 && gradedCount >= submissionsCount;
  int get pendingCount => (submissionsCount - gradedCount).clamp(0, submissionsCount);
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  String get fullFileUrl =>
      '${ApiEndpoints.baseUrl}/Cloud/Get/assignments/$fileUrl';

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) {
      final s = (v ?? '').toString().trim();
      return (s.isEmpty || s == 'null') ? null : s;
    }
    return AssignmentModel(
      id:               json['id']?.toString() ?? '',
      title:            json['title']?.toString() ?? '',
      description:      json['description']?.toString() ?? '',
      courseId:         json['courseId']?.toString() ?? json['course_id']?.toString() ?? '',
      sessionId:        json['sessionId']?.toString() ?? json['session_id']?.toString(),
      dueDate:          DateTime.tryParse(json['dueDate']?.toString() ?? json['due_date']?.toString() ?? ''),
      fileUrl:          str(json['fileUrl'] ?? json['file_url'] ?? json['materialUrl']),
      submissionsCount: (json['submissionsCount'] ?? json['submissions_count'] ?? json['totalSubmissions'] ?? 0) as int,
      gradedCount:      (json['gradedCount'] ?? json['graded_count'] ?? 0) as int,
    );
  }
}
