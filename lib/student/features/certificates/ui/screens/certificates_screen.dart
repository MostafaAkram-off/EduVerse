import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/mock_data.dart';
import 'certificate_detail_screen.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Certificates', style: AppTextTheme.screenTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Your verified achievements',
                      style: AppTextTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cert = MockData.certificates[index];
                    if (cert.isLocked) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LockedCertificateCard(item: cert),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CertificateCard(
                        item: cert,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CertificateDetailScreen(item: cert),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: MockData.certificates.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateItem item;
  final VoidCallback onTap;

  const _CertificateCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [item.color, item.color.withValues(alpha: 0.75)],
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'CERTIFICATE OF COMPLETION',
                          style: AppTextTheme.badgeSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: AppTextTheme.displaySmall.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Instructor: ${item.instructor}',
                      style: AppTextTheme.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.id} · ${item.date}',
                            style: AppTextTheme.timestamp
                                .copyWith(color: Colors.white60),
                          ),
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          onPressed: onTap,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Open'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCertificateCard extends StatelessWidget {
  final CertificateItem item;
  const _LockedCertificateCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.progressPercentIfLocked ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textTertiary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextTheme.bodySemibold,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: p / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.borderLight,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$p% complete – Keep going!',
                  style: AppTextTheme.timestamp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
