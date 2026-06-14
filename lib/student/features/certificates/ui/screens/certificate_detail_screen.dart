import 'package:flutter/material.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'certificates_screen.dart';

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key, required this.item});

  final CertItem item;

  @override
  Widget build(BuildContext context) {
    final studentName = AppPreferences.instance.userName.isNotEmpty
        ? AppPreferences.instance.userName
        : 'Student';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        title: Text('Certificate', style: AppTextTheme.displaySmall.copyWith(fontSize: 17)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EDUVERSE',
                                style: AppTextTheme.badgeSm.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Training Center',
                                style: AppTextTheme.bodySmall
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'CERTIFICATE OF COMPLETION',
                        style: AppTextTheme.badgeSm.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.4,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This certifies that',
                        style: AppTextTheme.timestamp.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studentName,
                        style: AppTextTheme.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'has successfully completed',
                        style: AppTextTheme.timestamp.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: AppTextTheme.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.instructor.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Instructor',
                                  style: AppTextTheme.timestamp
                                      .copyWith(color: Colors.white60),
                                ),
                                Text(
                                  item.instructor,
                                  style: AppTextTheme.bodySemibold
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          if (item.date.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Issue Date',
                                  style: AppTextTheme.timestamp
                                      .copyWith(color: Colors.white60),
                                ),
                                Text(
                                  item.date,
                                  style: AppTextTheme.bodySemibold
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(item: item),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: AppColors.success, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Certificate',
                        style: AppTextTheme.bodySemibold
                            .copyWith(color: AppColors.success),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Digital credential issued by EduVerse.',
                        style: AppTextTheme.timestamp
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF download coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('Download PDF'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('LinkedIn sharing coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Add to LinkedIn',
              style: AppTextTheme.bodySemibold
                  .copyWith(color: const Color(0xFF0A66C2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CertItem item;
  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      if (item.id.isNotEmpty) ['Certificate ID', item.id],
      ['Course', item.title],
      if (item.instructor.isNotEmpty) ['Instructor', item.instructor],
      if (item.date.isNotEmpty) ['Issue Date', item.date],
      ['Validity', 'Lifetime'],
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certificate information',
            style: AppTextTheme.displaySmall.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(r[0], style: AppTextTheme.bodySmall),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        r[1],
                        style: AppTextTheme.bodySemibold,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
