import 'package:flutter/material.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/enrollment/ui/screens/payment_tracking_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({
    super.key,
    this.onOpenCertificatesTab,
    this.onOpenLearningTab,
  });

  final VoidCallback? onOpenCertificatesTab;
  final VoidCallback? onOpenLearningTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final prefs = AppPreferences.instance;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.gradient1Start,
                        AppColors.gradient1End,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          prefs.initials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        prefs.userName,
                        style: AppTextTheme.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prefs.userEmail,
                        style: AppTextTheme.bodySmall.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prefs.userPhone,
                        style: AppTextTheme.timestamp.copyWith(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HeaderChip(
                            label: l10n.student,
                            bg: Colors.white24,
                            fg: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          _HeaderChip(
                            label: l10n.proMember,
                            bg: Colors.white,
                            fg: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _StatTile(
                        label: l10n.navCourses,
                        value: '5',
                        icon: Icons.school_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: l10n.certificates,
                        value: '2',
                        icon: Icons.workspace_premium_outlined,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: l10n.statHours,
                        value: '42h',
                        icon: Icons.schedule_rounded,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: _SectionLabel(l10n.account),
                ),
              ),
              SliverToBoxAdapter(
                child: _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      label: l10n.editProfile,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      label: l10n.changePassword,
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.mail_outline_rounded,
                      label: l10n.notificationPrefs,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _SectionLabel(l10n.learning),
                ),
              ),
              SliverToBoxAdapter(
                child: _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.menu_book_outlined,
                      label: l10n.myCourses,
                      onTap: onOpenLearningTab ?? () {},
                    ),
                    _MenuItem(
                      icon: Icons.payment_rounded,
                      label: l10n.paymentHistory,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const PaymentTrackingScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.workspace_premium_outlined,
                      label: l10n.certificates,
                      onTap: onOpenCertificatesTab ?? () {},
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _SectionLabel(l10n.support),
                ),
              ),
              SliverToBoxAdapter(
                child: _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: l10n.helpSupport,
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: l10n.settings,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppColors.errorLight,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.signOut,
                      style: AppTextTheme.bodySemibold.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _HeaderChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextTheme.badgeSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: AppTextTheme.badgeSm.copyWith(
        color: cs.onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
