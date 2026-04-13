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
}
