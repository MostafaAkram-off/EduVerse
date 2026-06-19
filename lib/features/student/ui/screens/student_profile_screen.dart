import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';
import 'package:edu_verse/features/student/ui/cubit/student_state.dart';
import 'package:edu_verse/student/features/certificates/ui/screens/certificates_screen.dart';
import 'package:edu_verse/student/features/notifications/ui/screens/notifications_screen.dart';
import 'package:edu_verse/core/screens/edit_profile_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  int? _certsCount;

  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(_onPrefsChanged);
    _fetchCertsCount();
  }

  Future<void> _fetchCertsCount() async {
    try {
      final dio = GetIt.instance<Dio>();
      final res = await dio.get<dynamic>(ApiEndpoints.myCertificates);
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['certificates'] ?? []) as List)
              : <dynamic>[];
      if (mounted) setState(() => _certsCount = list.length);
    } catch (_) {
      if (mounted) setState(() => _certsCount = 0);
    }
  }

  void _onPrefsChanged() => setState(() {});

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: TextStyle(color: ctx.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: ctx.textSecondary),
        ),
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

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surface,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Help & Support', style: AppTextTheme.displaySmall.copyWith(color: ctx.textPrimary)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradient1Start, AppColors.gradient1End],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Profile',
                            style: AppTextTheme.screenTitle.colored(Colors.white),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Avatar
                      _ProfileAvatar(
                        initials: AppPreferences.instance.initials(),
                        filename: AppPreferences.instance.profilePictureFilename,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppPreferences.instance.userName,
                        style: AppTextTheme.greetingName.colored(Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppPreferences.instance.userEmail,
                        style: AppTextTheme.bodySmall.colored(
                          Colors.white.withValues(alpha: 0.75),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats row ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<StudentCubit, StudentState>(
                builder: (context, state) {
                  final coursesCount = state is StudentLoaded ? state.courses.length : null;
                  final sessionsCount = state is StudentLoaded ? state.totalSessionsCount : null;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          icon: Icons.book_outlined,
                          value: coursesCount?.toString() ?? '—',
                          label: 'Courses',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatChip(
                          icon: Icons.calendar_today_outlined,
                          value: sessionsCount?.toString() ?? '—',
                          label: 'Sessions',
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatChip(
                          icon: Icons.workspace_premium_outlined,
                          value: _certsCount?.toString() ?? '—',
                          label: 'Certs',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      iconColor: AppColors.primary,
                      label: 'Edit Profile',
                      onTap: _openEditProfile,
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      label: 'Notifications',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      label: 'My Certificates',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CertificatesScreen(),
                        ),
                      ),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      iconColor: context.textSecondary,
                      label: 'Settings',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.success,
                      label: 'Help & Support',
                      onTap: () => _showHelpSheet(context),
                    ),
                    const Divider(height: 1, thickness: 1),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      label: 'Sign Out',
                      labelColor: AppColors.error,
                      showArrow: false,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}


// ─── Stat chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = color.withValues(alpha: context.isDark ? 0.2 : 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextTheme.statValue.colored(color)),
          ),
          Text(
            label,
            style: AppTextTheme.statLabel.copyWith(color: context.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Menu item ───────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final bool showArrow;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = labelColor ?? context.textPrimary;
    final iconBg = iconColor.withValues(alpha: context.isDark ? 0.2 : 0.12);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextTheme.cardTitle.colored(effectiveLabel),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.divider,
      indent: 66,
    );
  }
}

class _HelpRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HelpRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
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
              Text(label, style: AppTextTheme.bodySemibold.copyWith(color: context.textPrimary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextTheme.bodySmall.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String initials;
  final String filename;

  const _ProfileAvatar({required this.initials, required this.filename});

  @override
  Widget build(BuildContext context) {
    final photoUrl = filename.isNotEmpty
        ? '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(filename)}'
        : null;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                httpHeaders: AuthSession.token != null
                    ? {'Authorization': 'Bearer ${AuthSession.token}'}
                    : const {},
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Text(
                    initials,
                    style: AppTextTheme.displayMedium.colored(AppColors.primary),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: AppTextTheme.displayMedium.colored(AppColors.primary),
                ),
              ),
      ),
    );
  }
}
