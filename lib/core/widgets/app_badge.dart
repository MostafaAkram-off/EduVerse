import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

enum BadgeType { active, draft, warning, error, info, success, ongoing, upcoming, completed }

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, required this.type});

  final String label;
  final BadgeType type;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text) = switch (type) {
      BadgeType.active    => (AppColors.successLight,   AppColors.successDark),
      BadgeType.success   => (AppColors.successLight,   AppColors.successDark),
      BadgeType.completed => (AppColors.successLight,   AppColors.successDark),
      BadgeType.ongoing   => (AppColors.primaryLight,   AppColors.primaryDark),
      BadgeType.info      => (AppColors.primaryLight,   AppColors.primaryDark),
      BadgeType.upcoming  => (AppColors.primaryLight,   AppColors.primaryDark),
      BadgeType.warning   => (AppColors.warningLight,   AppColors.warning),
      BadgeType.draft     => (context.borderLight,      context.textSecondary),
      BadgeType.error     => (AppColors.errorLight,     AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextTheme.badgeSm.colored(text)),
    );
  }
}
