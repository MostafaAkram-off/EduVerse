import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    return switch (type) {
      'session' => Icons.event_note_rounded,
      'grade' => Icons.grade_rounded,
      'cert' => Icons.workspace_premium_rounded,
      'payment' => Icons.payment_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color _iconColor(String type) {
    return switch (type) {
      'session' => AppColors.primary,
      'grade' => AppColors.success,
      'cert' => AppColors.secondary,
      'payment' => AppColors.warning,
      _ => AppColors.textTertiary,
    };
  }

  Color _iconBg(String type) {
    return switch (type) {
      'session' => AppColors.primaryLight,
      'grade' => AppColors.successLight,
      'cert' => const Color(0xFFF5E6FF),
      'payment' => AppColors.warningLight,
      _ => AppColors.borderLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextTheme.displaySmall.copyWith(fontSize: 17),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.notifications.length,
        itemBuilder: (context, index) {
          final n = MockData.notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: n.isRead ? AppColors.surface : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: n.isRead
                          ? AppColors.borderLight
                          : AppColors.primary.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _iconBg(n.type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconFor(n.type),
                          color: _iconColor(n.type),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: AppTextTheme.bodySemibold,
                                  ),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: AppTextTheme.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n.timeLabel,
                              style: AppTextTheme.timestamp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
