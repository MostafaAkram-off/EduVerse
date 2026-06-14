import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_bottom_nav.dart';
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';
import 'package:edu_verse/features/student/ui/screens/student_home_screen.dart';
import 'package:edu_verse/features/student/ui/screens/student_profile_screen.dart';
import 'package:edu_verse/student/features/courses/ui/screens/courses_list_screen.dart';
import 'package:edu_verse/student/features/learning/ui/screens/my_learning_screen.dart';
import 'package:edu_verse/student/features/certificates/ui/screens/certificates_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    StudentHomeScreen(),
    CoursesListScreen(),
    MyLearningScreen(),
    CertificatesScreen(),
    StudentProfileScreen(),
  ];

  static const List<AppBottomNavItem> _navItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book_rounded,
      label: 'Courses',
    ),
    AppBottomNavItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_rounded,
      label: 'Learning',
    ),
    AppBottomNavItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium_rounded,
      label: 'Certs',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentCubit()..loadData(),
      child: Scaffold(
        extendBody: true,
        backgroundColor: context.bg,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: _navItems,
        ),
      ),
    );
  }
}
