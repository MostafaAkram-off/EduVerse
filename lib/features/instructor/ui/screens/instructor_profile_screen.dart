import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/widgets/app_avatar.dart';
import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

const _kGradientStart = Color(0xFFF97316);
const _kGradientEnd   = Color(0xFFEF4444);

// ─── Mock assignment reviews ──────────────────────────────────
class _Review {
  const _Review({
    required this.student,
    required this.assignment,
    required this.course,
    required this.submittedAgo,
    required this.grade,
  });
  final String student;
  final String assignment;
  final String course;
  final String submittedAgo;
  final String grade;
}

const _mockReviews = [
  _Review(student: 'Ahmed Khalid',  assignment: 'Flutter UI Challenge',   course: 'Mobile Dev',  submittedAgo: '2h ago',   grade: 'A'),
  _Review(student: 'Mona Hassan',   assignment: 'REST API Integration',   course: 'Mobile Dev',  submittedAgo: '5h ago',   grade: 'B+'),
  _Review(student: 'Youssef Nabil', assignment: 'Responsive Layout',      course: 'Web Dev',     submittedAgo: '1d ago',   grade: 'A-'),
  _Review(student: 'Fatima Ali',    assignment: 'State Management Quiz',  course: 'Mobile Dev',  submittedAgo: '1d ago',   grade: 'B'),
  _Review(student: 'Omar Samy',     assignment: 'CSS Grid Project',       course: 'Web Dev',     submittedAgo: '2d ago',   grade: 'A+'),
];

// ─── Screen ───────────────────────────────────────────────────

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key, this.onNavigateToTab});

  final void Function(int)? onNavigateToTab;

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState
    extends State<InstructorProfileScreen> {
  // Editable profile fields (local until API is ready)
  String _name           = 'Ahmed Hassan';
  String _specialization = 'Mobile & Web Development Instructor';
  String _email          = 'ahmed.hassan@eduverse.com';
  String _phone          = '+20 100 123 4567';

  // Notification toggles (local state)
  bool _notifyNewStudent       = true;
  bool _notifySessionReminder  = true;
  bool _notifyAssignments      = true;
  bool _notifyAppUpdates       = false;

  // ── Edit profile ──────────────────────────────────────────
  void _showEditProfile() {
    final nameCtrl  = TextEditingController(text: _name);
    final specCtrl  = TextEditingController(text: _specialization);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormSheet(
        title: 'Edit Profile',
        onSave: () {
          setState(() {
            _name           = nameCtrl.text.trim().isEmpty ? _name : nameCtrl.text.trim();
            _specialization = specCtrl.text.trim().isEmpty ? _specialization : specCtrl.text.trim();
            _email          = emailCtrl.text.trim().isEmpty ? _email : emailCtrl.text.trim();
            _phone          = phoneCtrl.text.trim().isEmpty ? _phone : phoneCtrl.text.trim();
          });
          Navigator.pop(context);
          _snack('Profile updated successfully');
        },
        child: Column(
          children: [
            _FormField(label: 'Full Name',       controller: nameCtrl,  icon: Icons.person_outline_rounded),
            _FormField(label: 'Specialization',  controller: specCtrl,  icon: Icons.work_outline_rounded),
            _FormField(label: 'Email',           controller: emailCtrl, icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress),
            _FormField(label: 'Phone',           controller: phoneCtrl, icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  // ── Change password ───────────────────────────────────────
  void _showChangePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => _FormSheet(
          title: 'Change Password',
          saveLabel: 'Update Password',
          onSave: () {
            if (currentCtrl.text.isEmpty) {
              setSheet(() => error = 'Enter your current password');
              return;
            }
            if (newCtrl.text.length < 6) {
              setSheet(() => error = 'New password must be at least 6 characters');
              return;
            }
            if (newCtrl.text != confirmCtrl.text) {
              setSheet(() => error = 'Passwords do not match');
              return;
            }
            Navigator.pop(context);
            _snack('Password updated successfully');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormField(label: 'Current Password', controller: currentCtrl,
                  icon: Icons.lock_outline_rounded, obscure: true),
              _FormField(label: 'New Password',     controller: newCtrl,
                  icon: Icons.lock_reset_rounded,   obscure: true),
              _FormField(label: 'Confirm New Password', controller: confirmCtrl,
                  icon: Icons.lock_rounded,          obscure: true),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style: AppTextTheme.labelSmall
                        .colored(AppColors.error)
                        .copyWith(fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Assignment reviews ────────────────────────────────────
  void _showAssignmentReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.93,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assignment Reviews',
                        style: AppTextTheme.displaySmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_mockReviews.length} pending',
                          style: AppTextTheme.labelSmall
                              .colored(AppColors.warning)
                              .copyWith(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: _mockReviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ReviewCard(review: _mockReviews[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notification preferences ──────────────────────────────
  void _showNotificationPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notification Preferences',
                          style: AppTextTheme.displaySmall),
                      const SizedBox(height: 4),
                      Text('Choose what you want to be notified about',
                          style: AppTextTheme.bodySmall),
                      const SizedBox(height: 20),
                      _ToggleTile(
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.primary,
                        label: 'New Student Enrolled',
                        subtitle: 'When a student joins your course',
                        value: _notifyNewStudent,
                        onChanged: (v) {
                          setSheet(() => _notifyNewStudent = v);
                          setState(() => _notifyNewStudent = v);
                        },
                      ),
                      _ToggleTile(
                        icon: Icons.calendar_today_outlined,
                        iconColor: AppColors.warning,
                        label: 'Session Reminders',
                        subtitle: '30 minutes before each session',
                        value: _notifySessionReminder,
                        onChanged: (v) {
                          setSheet(() => _notifySessionReminder = v);
                          setState(() => _notifySessionReminder = v);
                        },
                      ),
                      _ToggleTile(
                        icon: Icons.assignment_outlined,
                        iconColor: AppColors.success,
                        label: 'Assignment Submissions',
                        subtitle: 'When a student submits work',
                        value: _notifyAssignments,
                        onChanged: (v) {
                          setSheet(() => _notifyAssignments = v);
                          setState(() => _notifyAssignments = v);
                        },
                      ),
                      _ToggleTile(
                        icon: Icons.system_update_outlined,
                        iconColor: AppColors.textTertiary,
                        label: 'App Updates',
                        subtitle: 'News and feature announcements',
                        value: _notifyAppUpdates,
                        onChanged: (v) {
                          setSheet(() => _notifyAppUpdates = v);
                          setState(() => _notifyAppUpdates = v);
                        },
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
  }

  // ── App settings ──────────────────────────────────────────
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: AppTextTheme.displaySmall),
                    const SizedBox(height: 20),
                    _MenuCard(children: [
                      _MenuTile(
                        icon: Icons.language_rounded,
                        iconColor: AppColors.primary,
                        label: 'Language',
                        trailing: Text('English',
                            style: AppTextTheme.labelMedium
                                .colored(AppColors.textTertiary)),
                        onTap: () => _snack('Language settings coming soon'),
                      ),
                      _MenuTile(
                        icon: Icons.text_fields_rounded,
                        iconColor: AppColors.secondary,
                        label: 'Text Size',
                        trailing: Text('Default',
                            style: AppTextTheme.labelMedium
                                .colored(AppColors.textTertiary)),
                        onTap: () => _snack('Text size settings coming soon'),
                      ),
                      _MenuTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: AppColors.success,
                        label: 'Privacy Policy',
                        onTap: () => _snack('Opening privacy policy…'),
                      ),
                      _MenuTile(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.warning,
                        label: 'Terms of Service',
                        onTap: () => _snack('Opening terms of service…'),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'EduVerse v1.0.0',
                        style: AppTextTheme.timestamp,
                      ),
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

  // ── Sign out ──────────────────────────────────────────────
  void _showSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTextTheme.displaySmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextTheme.bodyMedium
              .colored(AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextTheme.buttonMedium
                    .colored(AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: clear auth tokens and navigate to login when API is ready
              _snack('Signed out');
            },
            child: Text('Sign Out',
                style: AppTextTheme.buttonMedium
                    .colored(AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorCubit, InstructorState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        body: switch (state) {
          InstructorError(:final message) => ErrorState(
              message: message,
              onRetry: () => context.read<InstructorCubit>().loadData(),
            ),
          InstructorLoaded(:final stats) => _buildBody(
              totalStudents: stats.totalStudents,
              activeCourses: stats.activeCourses,
            ),
          _ => _buildBody(totalStudents: 0, activeCourses: 0),
        },
      ),
    );
  }

  Widget _buildBody({
    required int totalStudents,
    required int activeCourses,
  }) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _ProfileHeader(name: _name, specialization: _specialization),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // Stats
              _StatsRow(
                students: totalStudents,
                courses: activeCourses,
                rating: 4.9,
              ),

              const SizedBox(height: 24),

              // ACCOUNT
              _SectionLabel('Account'),
              const SizedBox(height: 8),
              _MenuCard(children: [
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.warning,
                  label: 'Edit Profile',
                  onTap: _showEditProfile,
                ),
                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppColors.warning,
                  label: 'Change Password',
                  onTap: _showChangePassword,
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // TEACHING
              _SectionLabel('Teaching'),
              const SizedBox(height: 8),
              _MenuCard(children: [
                _MenuTile(
                  icon: Icons.calendar_month_outlined,
                  iconColor: AppColors.warning,
                  label: 'My Sessions',
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
                _MenuTile(
                  icon: Icons.people_outline_rounded,
                  iconColor: AppColors.warning,
                  label: 'My Students',
                  onTap: () => widget.onNavigateToTab?.call(2),
                ),
                _MenuTile(
                  icon: Icons.star_outline_rounded,
                  iconColor: AppColors.warning,
                  label: 'Assignment Reviews',
                  trailing: _badge('${_mockReviews.length}'),
                  onTap: _showAssignmentReviews,
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // SETTINGS
              _SectionLabel('Settings'),
              const SizedBox(height: 8),
              _MenuCard(children: [
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.warning,
                  label: 'Notification Preferences',
                  onTap: _showNotificationPreferences,
                ),
                _MenuTile(
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.warning,
                  label: 'Settings',
                  onTap: _showSettings,
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // Sign out
              _SignOutButton(onTap: _showSignOut),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: AppTextTheme.labelSmall
                .colored(AppColors.error)
                .copyWith(fontSize: 12)),
      );
}

// ─── Gradient header ─────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.specialization});
  final String name;
  final String specialization;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 210.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: headerHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kGradientStart, _kGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -30, right: -30,
            child: _Circle(size: 160, opacity: 0.07)),
        Positioned(top: 40, left: -40,
            child: _Circle(size: 120, opacity: 0.05)),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  child: AppAvatar(name: name, radius: 40),
                ),
                const SizedBox(height: 10),
                Text(name,
                    style: AppTextTheme.displaySmall
                        .colored(Colors.white)
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(specialization,
                    style: AppTextTheme.bodySmall
                        .colored(Colors.white.withValues(alpha: 0.80)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OutlineBadge(label: 'Instructor', color: AppColors.warning),
                    const SizedBox(width: 8),
                    _OutlineBadge(label: 'Verified',   color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _OutlineBadge extends StatelessWidget {
  const _OutlineBadge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.8)),
        ),
        child: Text(label,
            style: AppTextTheme.labelSmall
                .colored(color)
                .copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

// ─── Stats row ───────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.students,
    required this.courses,
    required this.rating,
  });
  final int students;
  final int courses;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _StatCell(value: '$students', label: 'Students',
              icon: Icons.people_alt_outlined,   iconColor: AppColors.primary),
          _VertDivider(),
          _StatCell(value: '$courses',  label: 'Courses',
              icon: Icons.menu_book_outlined,    iconColor: AppColors.warning),
          _VertDivider(),
          _StatCell(value: rating.toStringAsFixed(1), label: 'Rating',
              icon: Icons.star_outline_rounded,  iconColor: AppColors.success),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label,
      required this.icon, required this.iconColor});
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value,
                    style: AppTextTheme.statValue.colored(AppColors.textPrimary)),
                Text(label, style: AppTextTheme.statLabel),
              ]),
              const SizedBox(width: 8),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
        ),
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.borderLight);
}

// ─── Section label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(title.toUpperCase(), style: AppTextTheme.sectionHeader),
      );
}

// ─── Menu card ────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}

// ─── Menu tile ────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isLast = false,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: AppTextTheme.cardTitle)),
                if (trailing != null) ...[trailing!, const SizedBox(width: 6)],
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 66, endIndent: 0),
      ],
    );
  }
}

// ─── Sign out button ──────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Sign Out',
                    style: AppTextTheme.buttonMedium.colored(AppColors.error)),
              ],
            ),
          ),
        ),
      );
}

// ─── Bottom sheet handle ──────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

// ─── Generic form sheet ───────────────────────────────────────

class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.title,
    required this.child,
    required this.onSave,
    this.saveLabel = 'Save Changes',
  });
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              Text(title, style: AppTextTheme.displaySmall),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(saveLabel,
                      style: AppTextTheme.buttonMedium
                          .colored(AppColors.textOnPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form field ───────────────────────────────────────────────

class _FormField extends StatefulWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTextTheme.inputLabel),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(widget.icon, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: _hidden,
                    style: AppTextTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (widget.obscure)
                  IconButton(
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextTheme.cardTitle),
                Text(subtitle,
                    style: AppTextTheme.bodySmall
                        .colored(AppColors.textTertiary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─── Assignment review card ───────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final _Review review;

  Color get _gradeColor {
    final g = review.grade;
    if (g.startsWith('A')) return AppColors.success;
    if (g.startsWith('B')) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          AppAvatar(name: review.student, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.student, style: AppTextTheme.cardTitle),
                const SizedBox(height: 2),
                Text(review.assignment,
                    style: AppTextTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(review.course,
                        style: AppTextTheme.labelSmall
                            .colored(AppColors.primary)
                            .copyWith(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Text(review.submittedAgo,
                      style: AppTextTheme.timestamp),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _gradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(review.grade,
                      style: AppTextTheme.labelLarge
                          .colored(_gradeColor)),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Review for ${review.student} coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    duration: const Duration(seconds: 2),
                  ),
                ),
                child: Text('Review',
                    style: AppTextTheme.labelSmall
                        .colored(AppColors.primary)
                        .copyWith(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
