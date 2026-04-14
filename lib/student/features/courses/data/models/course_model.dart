import 'package:flutter/material.dart';

class CourseModel {
  final int id;
  final String title;
  final String instructor;
  final String category;
  final double rating;
  final int reviewsCount;
  final int studentsCount;
  final double price;
  final String duration;
  final String level;
  final int progressPercent; // 0 if not enrolled
  final bool isEnrolled;
  final Color color;
  final String description;
  final List<String> whatYouLearn;
  final List<String> modules;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.studentsCount,
    required this.price,
    required this.duration,
    required this.level,
    this.progressPercent = 0,
    this.isEnrolled = false,
    required this.color,
    this.description = '',
    this.whatYouLearn = const [],
    this.modules = const [],
  });

  CourseModel copyWith({
    bool? isEnrolled,
    int? progressPercent,
  }) {
    return CourseModel(
      id: id,
      title: title,
      instructor: instructor,
      category: category,
      rating: rating,
      reviewsCount: reviewsCount,
      studentsCount: studentsCount,
      price: price,
      duration: duration,
      level: level,
      progressPercent: progressPercent ?? this.progressPercent,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      color: color,
      description: description,
      whatYouLearn: whatYouLearn,
      modules: modules,
    );
  }
}