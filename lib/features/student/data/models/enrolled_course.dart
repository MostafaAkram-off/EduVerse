import 'package:flutter/material.dart';

class EnrolledCourse {
  final String id;
  final String title;
  final String instructorName;
  final String category;
  final int totalSessions;
  final int completedSessions;
  final List<Color> gradientColors;
  final double progressPercent;
  final String? nextSessionDate;

  const EnrolledCourse({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.category,
    required this.totalSessions,
    required this.completedSessions,
    required this.gradientColors,
    required this.progressPercent,
    required this.nextSessionDate,
  });

  int get remainingSessions => totalSessions - completedSessions;
}
