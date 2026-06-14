import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/widgets/app_bottom_nav.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_courses_screen.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_home_screen.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_profile_screen.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_sessions_screen.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_students_screen.dart';

class InstructorMainScreen extends StatefulWidget {
  const InstructorMainScreen({super.key});

  @override
  State<InstructorMainScreen> createState() =>
      _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  static const _navItems = [
    AppBottomNavItem(
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AppBottomNavItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book_rounded,
      label: 'Courses',
    ),
    AppBottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Sessions',
    ),
    AppBottomNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Students',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const InstructorHomeScreen(),
      const InstructorCoursesScreen(),
      const InstructorSessionsScreen(),
      const InstructorStudentsScreen(),
      InstructorProfileScreen(onNavigateToTab: _switchTab),
    ];

    return BlocProvider(
      create: (_) => GetIt.instance<InstructorCubit>()..loadData(),
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: _switchTab,
          items: _navItems,
        ),
      ),
    );
  }
}
