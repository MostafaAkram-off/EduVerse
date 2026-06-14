import 'package:flutter/material.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'package:edu_verse/student/features/learning/data/models/enrolled_course_model.dart';

// ============================================================
// MOCK DATA — EduVerse
// Single source of fake data used by all cubits during UI dev.
// Replace datasource impls with real API calls when backend ready.
// ============================================================

class MockData {
  MockData._();

  // ─────────────────────────────────────────
  // COURSES
  // ─────────────────────────────────────────
  static final List<CourseModel> courses = [
    CourseModel(
      id: '1',
      title: 'UI/UX Design Masterclass',
      instructor: 'Sarah Ahmed',
      category: 'Design',
      rating: 4.8,
      reviewsCount: 1240,
      studentsCount: 3200,
      price: 120,
      duration: '24h',
      level: 'Intermediate',
      progressPercent: 68,
      isEnrolled: true,
      color: const Color(0xFF7C3AED),
      description:
      'Master the complete UI/UX design workflow from research and wireframing '
          'to high-fidelity prototypes and handoff. This comprehensive course covers '
          'industry tools like Figma, design systems, and user testing methodologies.',
      whatYouLearn: [
        'Design thinking methodology',
        'Wireframing & prototyping with Figma',
        'Usability testing & iteration',
        'Design system creation',
        'Mobile-first design principles',
      ],
      modules: [
        'Module 1: Design Foundations',
        'Module 2: Research Methods',
        'Module 3: Wireframing',
        'Module 4: Prototyping',
        'Module 5: Testing & Iteration',
      ],
    ),
    CourseModel(
      id: '2',
      title: 'Flutter Development',
      instructor: 'Omar Hassan',
      category: 'Development',
      rating: 4.9,
      reviewsCount: 890,
      studentsCount: 2100,
      price: 150,
      duration: '36h',
      level: 'Beginner',
      progressPercent: 35,
      isEnrolled: true,
      color: const Color(0xFF0EA5E9),
      description:
      'Learn Flutter from scratch and build beautiful cross-platform apps for '
          'iOS and Android. Covers Dart fundamentals, widgets, state management, '
          'and publishing to app stores.',
      whatYouLearn: [
        'Dart programming language',
        'Flutter widget tree architecture',
        'State management with Bloc/Cubit',
        'REST API integration',
        'App publishing & CI/CD',
      ],
      modules: [
        'Module 1: Dart Fundamentals',
        'Module 2: Flutter Basics',
        'Module 3: Layouts & Widgets',
        'Module 4: State Management',
        'Module 5: API & Deployment',
      ],
    ),
    CourseModel(
      id: '3',
      title: 'Data Science with Python',
      instructor: 'Layla Nour',
      category: 'Data',
      rating: 4.7,
      reviewsCount: 2100,
      studentsCount: 5600,
      price: 200,
      duration: '48h',
      level: 'Advanced',
      isEnrolled: false,
      color: const Color(0xFF22C55E),
      description:
      'Deep dive into data science with Python. Learn pandas, NumPy, '
          'machine learning with scikit-learn, and data visualization.',
      whatYouLearn: [
        'Python for data analysis',
        'Pandas & NumPy',
        'Data visualization',
        'Machine learning basics',
        'Real-world projects',
      ],
      modules: [
        'Module 1: Python Refresher',
        'Module 2: Data Wrangling',
        'Module 3: Visualization',
        'Module 4: ML Algorithms',
        'Module 5: Capstone Project',
      ],
    ),
    CourseModel(
      id: '4',
      title: 'Digital Marketing Pro',
      instructor: 'Karim Ali',
      category: 'Marketing',
      rating: 4.6,
      reviewsCount: 780,
      studentsCount: 1800,
      price: 90,
      duration: '18h',
      level: 'Beginner',
      isEnrolled: false,
      color: const Color(0xFFF59E0B),
      description:
      'Master digital marketing strategies including SEO, social media, '
          'content marketing, email campaigns, and paid advertising.',
      whatYouLearn: [
        'SEO fundamentals',
        'Social media strategy',
        'Content marketing',
        'Email marketing',
        'Google Ads & Meta Ads',
      ],
      modules: [
        'Module 1: Marketing Foundations',
        'Module 2: SEO & Content',
        'Module 3: Social Media',
        'Module 4: Paid Advertising',
        'Module 5: Analytics',
      ],
    ),
    CourseModel(
      id: '5',
      title: 'Business Analytics',
      instructor: 'Nadia Fathi',
      category: 'Business',
      rating: 4.8,
      reviewsCount: 445,
      studentsCount: 920,
      price: 180,
      duration: '30h',
      level: 'Intermediate',
      isEnrolled: false,
      color: const Color(0xFFEF4444),
      description:
      'Learn how to analyze business data to drive strategic decisions. '
          'Covers Excel, Power BI, SQL, and storytelling with data.',
      whatYouLearn: [
        'Business intelligence fundamentals',
        'Excel & Power BI dashboards',
        'SQL for analytics',
        'KPI design',
        'Data storytelling',
      ],
      modules: [
        'Module 1: Analytics Foundations',
        'Module 2: Excel Mastery',
        'Module 3: SQL Basics',
        'Module 4: Power BI',
        'Module 5: Reporting',
      ],
    ),
  ];

  // ─────────────────────────────────────────
  // ENROLLED COURSES  (with sessions + assignments)
  // ─────────────────────────────────────────
  static final List<EnrolledCourseModel> enrolledCourses = [
    EnrolledCourseModel(
      course: courses[0], // UI/UX
      attendedSessions: 5,
      totalSessions: 8,
      sessions: const [
        SessionModel(
          id: 1,
          title: 'Introduction to Design Thinking',
          date: 'Mon, Mar 10',
          time: '10:00 AM',
          duration: '90 min',
          status: 'completed',
          isAttended: true,
        ),
        SessionModel(
          id: 2,
          title: 'Color Theory & Typography',
          date: 'Wed, Mar 12',
          time: '2:00 PM',
          duration: '90 min',
          status: 'upcoming',
          isAttended: false,
        ),
        SessionModel(
          id: 3,
          title: 'Wireframing Fundamentals',
          date: 'Mon, Mar 17',
          time: '10:00 AM',
          duration: '90 min',
          status: 'upcoming',
          isAttended: false,
        ),
      ],
      assignments: const [
        AssignmentModel(
          id: 1,
          title: 'User Research Report',
          dueDate: 'Mar 15',
          status: 'pending',
          maxPoints: 100,
        ),
        AssignmentModel(
          id: 2,
          title: 'Wireframe Prototype',
          dueDate: 'Mar 20',
          status: 'graded',
          grade: 92,
          maxPoints: 100,
        ),
      ],
    ),
    EnrolledCourseModel(
      course: courses[1], // Flutter
      attendedSessions: 3,
      totalSessions: 10,
      sessions: const [
        SessionModel(
          id: 3,
          title: 'Dart Fundamentals',
          date: 'Tue, Mar 11',
          time: '11:00 AM',
          duration: '120 min',
          status: 'live',
          isAttended: false,
        ),
        SessionModel(
          id: 4,
          title: 'Widget Tree Architecture',
          date: 'Thu, Mar 6',
          time: '11:00 AM',
          duration: '120 min',
          status: 'completed',
          isAttended: true,
        ),
      ],
      assignments: const [
        AssignmentModel(
          id: 3,
          title: 'Flutter Todo App',
          dueDate: 'Mar 12',
          status: 'graded',
          grade: 88,
          maxPoints: 100,
        ),
        AssignmentModel(
          id: 4,
          title: 'State Management Lab',
          dueDate: 'Mar 25',
          status: 'pending',
          maxPoints: 50,
        ),
      ],
    ),
  ];

  // ─────────────────────────────────────────
  // UPCOMING SESSIONS  (for home screen)
  // ─────────────────────────────────────────
  static const List<Map<String, dynamic>> upcomingSessions = [
    {
      'title': 'Introduction to Design Thinking',
      'course': 'UI/UX Design Masterclass',
      'date': 'Mon, Mar 10',
      'time': '10:00 AM',
      'status': 'upcoming',
    },
    {
      'title': 'Dart Fundamentals',
      'course': 'Flutter Development',
      'date': 'Tue, Mar 11',
      'time': '11:00 AM',
      'status': 'live',
    },
  ];

  // ─────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────
  static const List<String> categories = [
    'All',
    'Design',
    'Development',
    'Data',
    'Marketing',
    'Business',
  ];

  // ─────────────────────────────────────────
  // CERTIFICATES
  // ─────────────────────────────────────────
  static final List<CertificateItem> certificates = [
    CertificateItem(
      id: 'CERT-2026-001',
      title: 'UI/UX Design Fundamentals',
      date: 'Feb 2026',
      instructor: 'Sarah Ahmed',
      color: const Color(0xFF7C3AED),
      isLocked: false,
    ),
    CertificateItem(
      id: 'CERT-2026-002',
      title: 'Figma Advanced',
      date: 'Jan 2026',
      instructor: 'Sarah Ahmed',
      color: const Color(0xFF4A6CF7),
      isLocked: false,
    ),
    CertificateItem(
      id: 'CERT-PENDING-FLUTTER',
      title: 'Flutter Development',
      date: '',
      instructor: 'Omar Hassan',
      color: const Color(0xFF0EA5E9),
      isLocked: true,
      progressPercentIfLocked: 35,
    ),
  ];

  // ─────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────
  static final List<NotificationItem> notifications = [
    NotificationItem(
      id: 1,
      type: 'session',
      title: 'New Session Scheduled',
      message: 'UI/UX Design Masterclass – Mar 10, 10 AM',
      timeLabel: '2 min ago',
      isRead: false,
    ),
    NotificationItem(
      id: 2,
      type: 'grade',
      title: 'Assignment Graded',
      message: 'Your Flutter Todo App received 88/100',
      timeLabel: '1 hr ago',
      isRead: false,
    ),
    NotificationItem(
      id: 3,
      type: 'cert',
      title: 'Certificate Ready',
      message: 'UI/UX Design Fundamentals certificate is available',
      timeLabel: 'Yesterday',
      isRead: true,
    ),
    NotificationItem(
      id: 4,
      type: 'payment',
      title: 'Payment Confirmed',
      message: 'Payment of \$150 for Flutter Dev confirmed',
      timeLabel: '2 days ago',
      isRead: true,
    ),
  ];

  // ─────────────────────────────────────────
  // PAYMENTS (student ledger)
  // ─────────────────────────────────────────
  static final List<PaymentLedgerItem> paymentLedger = [
    PaymentLedgerItem(
      id: '1',
      courseTitle: 'UI/UX Design Masterclass',
      amount: 108,
      dateLabel: 'Mar 9, 2026',
      methodLabel: 'Credit Card **** 4242',
      status: PaymentStatus.paid,
      receiptId: '#EDU-2026-4821',
    ),
    PaymentLedgerItem(
      id: '2',
      courseTitle: 'Flutter Development',
      amount: 135,
      dateLabel: 'Feb 15, 2026',
      methodLabel: 'Bank Transfer',
      status: PaymentStatus.paid,
      receiptId: '#EDU-2026-3910',
    ),
    PaymentLedgerItem(
      id: '3',
      courseTitle: 'Data Science with Python',
      amount: 60,
      dateLabel: 'Apr 1, 2026',
      methodLabel: 'Installment 2/3',
      status: PaymentStatus.pending,
      receiptId: null,
    ),
  ];
}

class CertificateItem {
  final String id;
  final String title;
  final String date;
  final String instructor;
  final Color color;
  final bool isLocked;
  final int? progressPercentIfLocked;

  const CertificateItem({
    required this.id,
    required this.title,
    required this.date,
    required this.instructor,
    required this.color,
    this.isLocked = false,
    this.progressPercentIfLocked,
  });
}

class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String message;
  final String timeLabel;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.isRead,
  });
}

enum PaymentStatus { paid, pending, upcoming }

class PaymentLedgerItem {
  final String id;
  final String courseTitle;
  final double amount;
  final String dateLabel;
  final String methodLabel;
  final PaymentStatus status;
  final String? receiptId;

  const PaymentLedgerItem({
    required this.id,
    required this.courseTitle,
    required this.amount,
    required this.dateLabel,
    required this.methodLabel,
    required this.status,
    this.receiptId,
  });
}