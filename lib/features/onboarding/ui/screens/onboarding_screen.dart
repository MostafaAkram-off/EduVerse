import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/primary_button.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_state.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.school_outlined,
    gradientColors: [AppColors.primary, AppColors.secondary],
    title: 'Explore Courses',
    description:
        'Browse hundreds of expert-led courses designed to help you grow professionally.',
  ),
  _OnboardingPage(
    icon: Icons.track_changes_outlined,
    gradientColors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    title: 'Track Your Progress',
    description:
        'Attend sessions, submit assignments, and monitor your learning journey in real time.',
  ),
  _OnboardingPage(
    icon: Icons.workspace_premium_outlined,
    gradientColors: [Color(0xFFf7971e), Color(0xFFffd200)],
    title: 'Earn Certificates',
    description:
        'Complete courses and earn verified certificates to showcase your skills.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    AppPreferences.instance.setOnboardingSeen();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final currentPage = state.currentPage;
        final isLast = currentPage == _pages.length - 1;

        return Scaffold(
          backgroundColor: context.bg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        context.read<OnboardingCubit>().setPage(index),
                    itemBuilder: (context, index) =>
                        _PageContent(page: _pages[index]),
                  ),
                ),
                _BottomSection(
                  currentPage: currentPage,
                  isLast: isLast,
                  onSkip: _goToLogin,
                  onNext: () {
                    if (isLast) {
                      _goToLogin();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradientColors,
              ),
            ),
            child: Icon(page.icon, size: 88, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: AppTextTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextTheme.bodyMedium.copyWith(
              color: context.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.currentPage,
    required this.isLast,
    required this.onSkip,
    required this.onNext,
  });

  final int currentPage;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isSelected = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: AppTextTheme.buttonMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              if (!isLast) const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: isLast ? 'Get Started' : 'Next',
                  onPressed: onNext,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
