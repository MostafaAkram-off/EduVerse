class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.isPresent,
    this.markedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final bool isPresent;
  final DateTime? markedAt;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id:           json['id']?.toString() ?? '',
      studentId:    json['studentId']?.toString() ?? json['student_id']?.toString() ?? json['userId']?.toString() ?? '',
      studentName:  json['studentName']?.toString() ?? json['student_name']?.toString() ?? json['name']?.toString() ?? json['userName']?.toString() ?? '',
      studentEmail: json['studentEmail']?.toString() ?? json['student_email']?.toString() ?? json['email']?.toString() ?? '',
      isPresent:    (json['isPresent'] as bool?) ?? (json['is_present'] as bool?) ?? true,
      markedAt:     DateTime.tryParse(json['markedAt']?.toString() ?? json['marked_at']?.toString() ?? json['attendedAt']?.toString() ?? ''),
    );
  }
}
