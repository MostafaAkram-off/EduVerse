import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import '../../../home/ui/screens/student_home_screen.dart';
import '../../../courses/ui/screens/courses_list_screen.dart';
import '../../../learning/ui/screens/my_learning_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  // Keep screens alive when switching tabs
  final List<Widget> _screens = const [
    StudentHomeScreen(),
    CoursesListScreen(),
    MyLearningScreen(),
    _PlaceholderScreen(icon: Icons.workspace_premium_outlined, label: 'Certificates'),
    _PlaceholderScreen(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _NavTab(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,                label: 'Home'),
    _NavTab(icon: Icons.menu_book_outlined,     activeIcon: Icons.menu_book_rounded,           label: 'Courses'),
    _NavTab(icon: Icons.school_outlined,        activeIcon: Icons.school_rounded,              label: 'My Learning'),
    _NavTab(icon: Icons.workspace_premium_outlined, activeIcon: Icons.workspace_premium_rounded, label: 'Certificates'),
    _NavTab(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,              label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(
              _tabs.length,
                  (index) => Expanded(
                child: _NavItem(
                  tab: _tabs[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 40 : 0,
            height: isActive ? 28 : 28,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 20,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tab.label,
            style: isActive ? AppTextTheme.navActive : AppTextTheme.navInactive,
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─────────────────────────────────────────────
// PLACEHOLDER  (for tabs not built yet)
// ─────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderScreen({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(label,
                  style: AppTextTheme.displaySmall.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: AppTextTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}