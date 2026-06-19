import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final navLabelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );

    final screens = [
      InstructorHomeScreen(onNavigateToTab: _switchTab),
      const InstructorCoursesScreen(),
      const InstructorSessionsScreen(),
      const InstructorStudentsScreen(),
      InstructorProfileScreen(onNavigateToTab: _switchTab),
    ];

    return BlocProvider(
      create: (_) => GetIt.instance<InstructorCubit>()..loadData(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Material(
            elevation: 18,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: SalomonBottomBar(
              margin: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              currentIndex: _currentIndex,
              onTap: _switchTab,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: cs.onSurface.withValues(alpha: 0.42),
              selectedColorOpacity: 0.12,
              itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.dashboard_outlined),
                  activeIcon: const Icon(Icons.dashboard_rounded),
                  title: Text('Dashboard', maxLines: 1, style: navLabelStyle),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.book_outlined),
                  activeIcon: const Icon(Icons.book_rounded),
                  title: Text('Courses', maxLines: 1, style: navLabelStyle),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.calendar_today_outlined),
                  activeIcon: const Icon(Icons.calendar_today_rounded),
                  title: Text('Sessions', maxLines: 1, style: navLabelStyle),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.people_outline_rounded),
                  activeIcon: const Icon(Icons.people_rounded),
                  title: Text('Students', maxLines: 1, style: navLabelStyle),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  title: Text('Profile', maxLines: 1, style: navLabelStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
