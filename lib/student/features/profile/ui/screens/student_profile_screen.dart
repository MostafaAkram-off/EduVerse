import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/student/features/enrollment/ui/screens/payment_tracking_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({
    super.key,
    this.onOpenCertificatesTab,
    this.onOpenLearningTab,
  });

  final VoidCallback? onOpenCertificatesTab;
  final VoidCallback? onOpenLearningTab;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  int? _coursesCount;
  int? _certsCount;

  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(_onPrefsChanged);
    _fetchStats();
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() => setState(() {});

  Future<void> _fetchStats() async {
    final dio = GetIt.instance<Dio>();
    await Future.wait([
      dio.get<dynamic>(ApiEndpoints.myEnrolledCourses).then((r) {
        final raw = r.data;
        final list = raw is List ? raw : (raw is Map ? ((raw['data'] ?? raw['courses'] ?? []) as List) : []);
        if (mounted) setState(() => _coursesCount = list.length);
      }).catchError((_) { if (mounted) setState(() => _coursesCount = 0); }),
      dio.get<dynamic>(ApiEndpoints.myCertificates).then((r) {
        final raw = r.data;
        final list = raw is List ? raw : (raw is Map ? ((raw['data'] ?? raw['certificates'] ?? []) as List) : []);
        if (mounted) setState(() => _certsCount = list.length);
      }).catchError((_) { if (mounted) setState(() => _certsCount = 0); }),
    ]);
  }

  Future<void> _showChangePassword() async {
    final formKey = GlobalKey<FormState>();
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 20, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: ctx.borderLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Change Password', style: AppTextTheme.displaySmall),
                const SizedBox(height: 20),
                _PwField(ctrl: currentCtrl, label: 'Current password'),
                const SizedBox(height: 12),
                _PwField(
                  ctrl: newCtrl,
                  label: 'New password',
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Minimum 8 characters' : null,
                ),
                const SizedBox(height: 12),
                _PwField(
                  ctrl: confirmCtrl,
                  label: 'Confirm new password',
                  validator: (v) => v != newCtrl.text ? 'Passwords do not match' : null,
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(errorMsg!, style: AppTextTheme.bodySmall.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      final dio = GetIt.instance<Dio>();
                      await dio.post<dynamic>(
                        ApiEndpoints.changePassword,
                        data: {
                          'currentPassword': currentCtrl.text,
                          'newPassword': newCtrl.text,
                        },
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } on DioException catch (e) {
                      final msg = e.response?.data?['message']?.toString()
                          ?? 'Incorrect current password';
                      setSheet(() => errorMsg = msg);
                    } catch (_) {
                      setSheet(() => errorMsg = 'Something went wrong. Try again.');
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Update Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  void _showHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Help & Support', style: AppTextTheme.displaySmall),
            const SizedBox(height: 16),
            _HelpRow(
              icon: Icons.email_outlined,
              label: 'Email us',
              value: 'support@eduverse.app',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _HelpRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Live chat',
              value: 'Available 9 AM – 6 PM (Sun–Thu)',
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            _HelpRow(
              icon: Icons.info_outline_rounded,
              label: 'FAQ',
              value: 'Visit our help center for answers',
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      AuthSession.clear();
      await AppPreferences.instance.clearSession();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final l10n  = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradient1Start, AppColors.gradient1End],
                ),
              ),
              child: Column(
                children: [
                  _ProfileAvatar(
                    radius: 40,
                    initials: prefs.initials(),
                    photoUrl: prefs.profilePictureFilename.isNotEmpty
                        ? '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(prefs.profilePictureFilename)}'
                        : null,
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
                  if (prefs.userPhone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      prefs.userPhone,
                      style: AppTextTheme.timestamp.copyWith(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeaderChip(label: l10n.student, bg: Colors.white24, fg: Colors.white),
                      const SizedBox(width: 8),
                      _HeaderChip(label: l10n.proMember, bg: Colors.white, fg: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Stats row ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _StatTile(
                    label: l10n.navCourses,
                    value: _coursesCount?.toString() ?? '—',
                    icon: Icons.school_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    label: l10n.certificates,
                    value: _certsCount?.toString() ?? '—',
                    icon: Icons.workspace_premium_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    label: l10n.statHours,
                    value: _coursesCount != null
                        ? '${(_coursesCount! * 6)}h'
                        : '—',
                    icon: Icons.schedule_rounded,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
          ),

          // ── Account section ──────────────────────────────────
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
                    MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  label: l10n.changePassword,
                  onTap: _showChangePassword,
                ),
                _MenuItem(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.notificationPrefs,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),

          // ── Learning section ─────────────────────────────────
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
                  onTap: widget.onOpenLearningTab ?? () {},
                ),
                _MenuItem(
                  icon: Icons.payment_rounded,
                  label: l10n.paymentHistory,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const PaymentTrackingScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: l10n.certificates,
                  onTap: widget.onOpenCertificatesTab ?? () {},
                ),
              ],
            ),
          ),

          // ── Support section ──────────────────────────────────
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
                  onTap: _showHelpSheet,
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: l10n.settings,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),

          // ── Sign out ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: OutlinedButton(
                onPressed: _confirmLogout,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  l10n.signOut,
                  style: AppTextTheme.bodySemibold.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _PwField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  final String? Function(String?)? validator;
  const _PwField({required this.ctrl, required this.label, this.validator});

  @override
  State<_PwField> createState() => _PwFieldState();
}

class _PwFieldState extends State<_PwField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HelpRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextTheme.bodySemibold),
              const SizedBox(height: 2),
              Text(value, style: AppTextTheme.bodySmall.copyWith(color: context.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  final String? photoUrl;
  const _ProfileAvatar({required this.radius, required this.initials, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: Text(initials, style: TextStyle(color: Colors.white, fontSize: radius * 0.7, fontWeight: FontWeight.w800)),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Text(initials, style: TextStyle(color: Colors.white, fontSize: radius * 0.7, fontWeight: FontWeight.w800)),
                ),
              )
            : Center(
                child: Text(initials, style: TextStyle(color: Colors.white, fontSize: radius * 0.7, fontWeight: FontWeight.w800)),
              ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _HeaderChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextTheme.badgeSm.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

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
                Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
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
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
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
  const _MenuItem({required this.icon, required this.label, required this.onTap});

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
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
