import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/student/features/certificates/ui/screens/certificates_screen.dart';
import 'package:edu_verse/student/features/notifications/ui/screens/notifications_screen.dart';
import 'package:edu_verse/student/features/profile/ui/screens/student_profile_screen.dart';
import 'student_home_screen.dart';
import '../../../courses/ui/screens/courses_list_screen.dart';
import '../../../learning/ui/screens/my_learning_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  // Only the Home tab (index 0) loads on startup.
  // Other tabs are lazily initialized on first visit.
  final Set<int> _visited = {0};

  void _setTab(int index) {
    setState(() {
      _visited.add(index);
      _currentIndex = index;
    });
  }

  void _openNotifications() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  Widget _lazyPage(int index, Widget child) {
    // Until a tab is first visited we render an empty box so the tab's
    // initState / API calls are deferred until the user actually opens it.
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final navLabelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0 — always loaded
          StudentHomeScreen(
            onSwitchTab: _setTab,
            onOpenNotifications: _openNotifications,
          ),
          // Tab 1 — Courses (lazy)
          _lazyPage(1, const CoursesListScreen()),
          // Tab 2 — My Learning (lazy)
          _lazyPage(2, const MyLearningScreen()),
          // Tab 3 — Certificates (lazy)
          _lazyPage(3, const CertificatesScreen()),
          // Tab 4 — Profile (lazy)
          _lazyPage(
            4,
            StudentProfileScreen(
              onOpenCertificatesTab: () => _setTab(3),
              onOpenLearningTab: () => _setTab(2),
            ),
          ),
        ],
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
            onTap: _setTab,
            selectedItemColor: cs.primary,
            unselectedItemColor: cs.onSurface.withValues(alpha: 0.42),
            selectedColorOpacity: 0.12,
            itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                title: Text(
                  l10n.navHome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: navLabelStyle,
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(Icons.menu_book_rounded),
                title: Text(
                  l10n.navCourses,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: navLabelStyle,
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.school_outlined),
                activeIcon: const Icon(Icons.school_rounded),
                title: Text(
                  l10n.navLearning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: navLabelStyle,
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.workspace_premium_outlined),
                activeIcon: const Icon(Icons.workspace_premium_rounded),
                title: Text(
                  l10n.navCertificates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: navLabelStyle,
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                title: Text(
                  l10n.navProfile,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: navLabelStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
