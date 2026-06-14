import 'package:flutter/material.dart';
import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';

class StudentMock {
  StudentMock._();

  static List<EnrolledCourse> get courses => [
    const EnrolledCourse(
      id: 'sc1',
      title: 'Flutter Advanced UI',
      instructorName: 'Ahmed Hassan',
      category: 'Mobile Dev',
      totalSessions: 12,
      completedSessions: 8,
      progressPercent: 0.68,
      gradientColors: [Color(0xFF4A6CF7), Color(0xFF7C3AED)],
      nextSessionDate: 'Tomorrow, 9:00 AM',
    ),
    const EnrolledCourse(
      id: 'sc2',
      title: 'React Native Fundamentals',
      instructorName: 'Ahmed Hassan',
      category: 'Mobile Dev',
      totalSessions: 10,
      completedSessions: 4,
      progressPercent: 0.40,
      gradientColors: [Color(0xFF22C55E), Color(0xFF059669)],
      nextSessionDate: 'Fri, 2:00 PM',
    ),
    const EnrolledCourse(
      id: 'sc3',
      title: 'UI/UX Design Principles',
      instructorName: 'Ahmed Hassan',
      category: 'Design',
      totalSessions: 9,
      completedSessions: 9,
      progressPercent: 1.0,
      gradientColors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
      nextSessionDate: null,
    ),
    const EnrolledCourse(
      id: 'sc4',
      title: 'Backend with Node.js',
      instructorName: 'Ahmed Hassan',
      category: 'Web Dev',
      totalSessions: 8,
      completedSessions: 2,
      progressPercent: 0.25,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      nextSessionDate: 'Mon, 11:00 AM',
    ),
  ];

  static final _now = DateTime.now();

  static List<StudentSession> get sessions => [
    StudentSession(
      id: 'ss1',
      courseTitle: 'Flutter Advanced UI',
      instructorName: 'Ahmed Hassan',
      location: 'Room 204',
      startTime: DateTime(_now.year, _now.month, _now.day, 13, 0),
      endTime: DateTime(_now.year, _now.month, _now.day, 14, 30),
      isOnline: false,
      status: StudentSessionStatus.ongoing,
    ),
    StudentSession(
      id: 'ss2',
      courseTitle: 'React Native Fundamentals',
      instructorName: 'Ahmed Hassan',
      location: 'Zoom',
      startTime: DateTime(_now.year, _now.month, _now.day, 16, 0),
      endTime: DateTime(_now.year, _now.month, _now.day, 17, 30),
      isOnline: true,
      status: StudentSessionStatus.upcoming,
    ),
    StudentSession(
      id: 'ss3',
      courseTitle: 'Flutter Advanced UI',
      instructorName: 'Ahmed Hassan',
      location: 'Room 204',
      startTime: _now.add(const Duration(days: 1, hours: 2)),
      endTime: _now.add(const Duration(days: 1, hours: 3, minutes: 30)),
      isOnline: false,
      status: StudentSessionStatus.upcoming,
    ),
    StudentSession(
      id: 'ss4',
      courseTitle: 'Backend with Node.js',
      instructorName: 'Ahmed Hassan',
      location: 'Google Meet',
      startTime: _now.add(const Duration(days: 3, hours: 1)),
      endTime: _now.add(const Duration(days: 3, hours: 2, minutes: 30)),
      isOnline: true,
      status: StudentSessionStatus.upcoming,
    ),
  ];
}
