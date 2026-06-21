import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final double rating;
  final int reviewsCount;
  final int studentsCount;
  final double price;
  final String duration;
  final String level;
  final int progressPercent;
  final bool isEnrolled;
  final Color color;
  final String description;
  final List<String> whatYouLearn;
  final List<String> modules;
  final String? imageUrl;
  final String instructorBio;
  final String? instructorPhotoUrl;

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
    this.imageUrl,
    this.instructorBio = '',
    this.instructorPhotoUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List?)
            ?.map((c) => (c as Map<String, dynamic>)['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];
    final category = cats.isNotEmpty ? cats.first : 'General';
    final durationHours = (json['duration'] as num?)?.toDouble() ?? 0.0;

    final instructorBio = json['instructorBio'] as String? ??
        json['instructorDescription'] as String? ??
        json['trainerBio'] as String? ??
        '';

    final instructorPhotoUrl = json['instructorPhotoUrl'] as String? ??
        json['instructorPhoto'] as String? ??
        json['trainerPhoto'] as String? ??
        json['trainerPhotoUrl'] as String?;

    return CourseModel(
      id:           json['id'] as String? ?? '',
      title:        json['title'] as String? ?? json['name'] as String? ?? '',
      instructor:   json['instructorName'] as String? ??
                    json['instructor'] as String? ??
                    json['trainerName'] as String? ??
                    json['createdBy'] as String? ?? '',
      category:     category,
      rating:       (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      studentsCount: json['studentsCount'] as int? ?? 0,
      price:        (json['price'] as num?)?.toDouble() ?? 0.0,
      duration:     _formatHours(durationHours),
      level:        json['level'] as String? ?? '',
      imageUrl:     json['imageUrl'] as String?,
      color:        _categoryColor(category),
      description:  json['description'] as String? ?? '',
      whatYouLearn: _parseStringList(json, const [
        'whatYouLearn', 'what_you_learn', 'learningOutcomes',
        'objectives', 'outcomes', 'skills', 'whatWillYouLearn',
      ]),
      instructorBio:      instructorBio,
      instructorPhotoUrl: instructorPhotoUrl,
    );
  }

  static List<String> _parseStringList(
      Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final val = json[key];
      if (val is List && val.isNotEmpty) {
        final items = val
            .map((e) => e?.toString().trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        if (items.isNotEmpty) return items;
      }
      if (val is String && val.trim().isNotEmpty) {
        return val
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }

  CourseModel copyWith({bool? isEnrolled, int? progressPercent}) {
    return CourseModel(
      id: id, title: title, instructor: instructor, category: category,
      rating: rating, reviewsCount: reviewsCount, studentsCount: studentsCount,
      price: price, duration: duration, level: level,
      progressPercent: progressPercent ?? this.progressPercent,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      color: color, description: description,
      whatYouLearn: whatYouLearn, modules: modules, imageUrl: imageUrl,
      instructorBio: instructorBio, instructorPhotoUrl: instructorPhotoUrl,
    );
  }

  static String _formatHours(double hours) {
    if (hours <= 0) return '';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'backend':      return const Color(0xFF4A6CF7);
      case 'frontend':     return const Color(0xFF0EA5E9);
      case 'mobile':
      case 'mobile dev':   return const Color(0xFF7C3AED);
      case 'design':       return const Color(0xFFEC4899);
      case 'data':         return const Color(0xFF22C55E);
      case 'marketing':    return const Color(0xFFF59E0B);
      case 'business':     return const Color(0xFFEF4444);
      case 'devops':
      case 'infrastructure': return const Color(0xFF475569);
      default:             return const Color(0xFF4A6CF7);
    }
  }
}
