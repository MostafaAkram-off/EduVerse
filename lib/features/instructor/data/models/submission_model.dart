class SubmissionModel {
  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.courseTitle,
    required this.submittedAt,
    this.fileUrl,
    this.notes,
    this.grade,
    this.feedback,
    this.isGraded = false,
  });

  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String courseTitle;
  final DateTime submittedAt;
  final String? fileUrl;
  final String? notes;
  final String? grade;
  final String? feedback;
  final bool isGraded;

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    // API returns grade as double (0-100); format to "90" not "90.0"
    final rawGrade = json['grade'];
    final String? gradeVal = rawGrade == null
        ? null
        : rawGrade is num
            ? rawGrade.toStringAsFixed(0)
            : rawGrade.toString();
    return SubmissionModel(
      id:              json['id']?.toString() ?? '',
      assignmentId:    json['assignmentId']?.toString() ?? json['assignment_id']?.toString() ?? '',
      assignmentTitle: json['assignmentTitle']?.toString() ?? json['assignment_title']?.toString() ?? json['assignmentName']?.toString() ?? '',
      studentId:       json['studentId']?.toString() ?? json['student_id']?.toString() ?? json['userId']?.toString() ?? '',
      studentName:     json['studentName']?.toString() ?? json['student_name']?.toString() ?? json['userName']?.toString() ?? json['name']?.toString() ?? '',
      studentEmail:    json['studentEmail']?.toString() ?? json['student_email']?.toString() ?? json['email']?.toString() ?? '',
      courseTitle:     json['courseTitle']?.toString() ?? json['course_title']?.toString() ?? '',
      submittedAt:     DateTime.tryParse(json['submittedAt']?.toString() ?? json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
      fileUrl:         json['fileUrl']?.toString() ?? json['file_url']?.toString(),
      notes:           json['notes']?.toString() ?? json['content']?.toString(),
      grade:           gradeVal,
      feedback:        json['feedback']?.toString() ?? json['comment']?.toString(),
      isGraded:        (json['isGraded'] as bool?) ?? (json['is_graded'] as bool?) ?? (gradeVal != null && gradeVal.isNotEmpty),
    );
  }

  SubmissionModel copyWith({String? grade, String? feedback, bool? isGraded}) =>
      SubmissionModel(
        id: id, assignmentId: assignmentId, assignmentTitle: assignmentTitle,
        studentId: studentId, studentName: studentName, studentEmail: studentEmail,
        courseTitle: courseTitle, submittedAt: submittedAt, fileUrl: fileUrl, notes: notes,
        grade: grade ?? this.grade,
        feedback: feedback ?? this.feedback,
        isGraded: isGraded ?? this.isGraded,
      );
}
