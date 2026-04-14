import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

enum BadgeType { active, draft, warning, error, info, success, ongoing, upcoming, completed }

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, required this.type});

  final String label;
  final BadgeType type;

  static ({Color bg, Color text}) _colors(BadgeType t) => switch (t) {
    BadgeType.active    => (bg: AppColors.successLight,   text: AppColors.successDark),
    BadgeType.success   => (bg: AppColors.successLight,   text: AppColors.successDark),
    BadgeType.completed => (bg: AppColors.successLight,   text: AppColors.successDark),
    BadgeType.ongoing   => (bg: AppColors.primaryLight,   text: AppColors.primaryDark),
    BadgeType.info      => (bg: AppColors.primaryLight,   text: AppColors.primaryDark),
    BadgeType.upcoming  => (bg: AppColors.primaryLight,   text: AppColors.primaryDark),
    BadgeType.warning   => (bg: AppColors.warningLight,   text: AppColors.warning),
    BadgeType.draft     => (bg: AppColors.borderLight,    text: AppColors.textSecondary),
    BadgeType.error     => (bg: AppColors.errorLight,     text: AppColors.error),
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextTheme.badgeSm.colored(c.text)),
    );
  }
}
