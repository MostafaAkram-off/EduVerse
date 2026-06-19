import 'package:flutter/material.dart';

enum CourseStatus { active, draft }

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.studentsCount,
    required this.sessionsCount,
    required this.status,
    required this.coverGradient,
    required this.createdAt,
    this.completionRate = 0,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int studentsCount;
  final int sessionsCount;
  final CourseStatus status;
  final List<Color> coverGradient;
  final DateTime createdAt;
  final double completionRate; // 0.0–1.0

  String get statusLabel =>
      status == CourseStatus.active ? 'Active' : 'Draft';

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['courseId'] ?? '').toString();
    final category = (json['category'] ??
            json['categoryName'] ??
            json['subject'] ??
            'General')
        .toString();

    final statusStr =
        (json['status'] ?? json['courseStatus'] ?? '').toString().toLowerCase();
    final status =
        statusStr == 'draft' ? CourseStatus.draft : CourseStatus.active;

    final rawRate = json['completionRate'] ??
        json['completion_rate'] ??
        json['progress'] ??
        0;
    var rate = (rawRate is int ? rawRate.toDouble() : (rawRate as num).toDouble());
    if (rate > 1.0) rate = rate / 100.0;
    final completionRate = rate.clamp(0.0, 1.0);

    return CourseModel(
      id: rawId,
      title: (json['title'] ?? json['courseName'] ?? json['name'] ?? 'Course')
          .toString(),
      category: category,
      description:
          (json['description'] ?? json['about'] ?? '').toString(),
      studentsCount:
          (json['studentsCount'] ?? json['enrolledStudents'] ?? json['students'] ?? 0) as int,
      sessionsCount:
          (json['sessionsCount'] ?? json['sessions'] ?? 0) as int,
      status: status,
      coverGradient: _gradientFor(category, rawId),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completionRate: completionRate,
    );
  }

  static List<Color> _gradientFor(String category, String id) {
    switch (category.toLowerCase()) {
      case 'mobile dev':
        return const [Color(0xFF4A6CF7), Color(0xFF7C3AED)];
      case 'web dev':
        return const [Color(0xFF22C55E), Color(0xFF059669)];
      case 'design':
        return const [Color(0xFF7C3AED), Color(0xFFEC4899)];
      case 'data':
        return const [Color(0xFF0EA5E9), Color(0xFF6366F1)];
      case 'infrastructure':
        return const [Color(0xFF475569), Color(0xFF0F172A)];
      default:
        final hash = id.hashCode.abs() % _defaultGradients.length;
        return _defaultGradients[hash];
    }
  }

  static const _defaultGradients = [
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF4A6CF7), Color(0xFF7C3AED)],
    [Color(0xFF22C55E), Color(0xFF059669)],
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
  ];
}
