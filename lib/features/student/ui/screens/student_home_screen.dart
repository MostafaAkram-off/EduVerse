import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';
import 'package:edu_verse/features/student/ui/cubit/student_state.dart';
import 'package:edu_verse/features/student/ui/screens/student_course_detail_screen.dart';
import 'package:edu_verse/student/features/notifications/ui/screens/notifications_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width < 360 ? 12.0 : 20.0;

    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            if (state is StudentLoading || state is StudentInitial)
              _buildShimmer(context, hPadding)
            else if (state is StudentLoaded)
              _buildBody(context, state, hPadding)
            else if (state is StudentError)
              SliverFillRemaining(
                child: _ErrorView(
                  message: (state).message,
                  onRetry: () => context.read<StudentCubit>().loadData(),
                ),
              )
            else
              _buildShimmer(context, hPadding),
          ],
        );
      },
    );
  }

  // ─── App bar ────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradient1Start, AppColors.gradient1End],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_greeting(),
                      style: AppTextTheme.greeting.colored(Colors.white70)),
                  const SizedBox(height: 2),
                  Text(
                    AuthSession.name,
                    style: AppTextTheme.greetingName.colored(Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(_formatDate(),
                      style: AppTextTheme.labelMedium.colored(Colors.white60)),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const NotificationsScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: AppColors.warning, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Loaded body ────────────────────────────────────────────
  SliverPadding _buildBody(
      BuildContext context, StudentLoaded state, double hPadding) {
    final now = DateTime.now();
    final todaySessions = state.sessions
        .where((s) =>
            s.startTime.day == now.day &&
            s.startTime.month == now.month &&
            s.startTime.year == now.year &&
            (s.status == StudentSessionStatus.ongoing ||
                s.status == StudentSessionStatus.upcoming))
        .toList();
    final upcomingSessions = state.sessions
        .where((s) => !(s.startTime.day == now.day &&
            s.startTime.month == now.month &&
            s.startTime.year == now.year))
        .toList();

    final completedCount =
        state.courses.where((c) => c.progressPercent >= 1.0).length;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 20),

          // ── Stats ──────────────────────────────
          Row(children: [
            Expanded(
              child: _StatChip(
                icon: Icons.book_outlined,
                value: '${state.courses.length}',
                label: 'Enrolled',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: Icons.check_circle_outline_rounded,
                value: '$completedCount',
                label: 'Completed',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: Icons.calendar_today_outlined,
                value: '${todaySessions.length}',
                label: 'Sessions',
                color: AppColors.warning,
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── Continue Learning ──────────────────
          if (state.courses.isNotEmpty) ...[
            Text('Continue Learning',
                style: AppTextTheme.displaySmall
                    .copyWith(color: context.textPrimary)),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.courses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) => _CourseCard(
                  course: state.courses[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StudentCourseDetailScreen(
                          course: state.courses[i]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Today's Sessions ───────────────────
          Text("Today's Sessions",
              style: AppTextTheme.displaySmall
                  .copyWith(color: context.textPrimary)),
          const SizedBox(height: 12),
          if (todaySessions.isEmpty)
            _EmptySection(message: 'No sessions scheduled for today')
          else
            ...todaySessions.map((s) => _SessionTile(
                  session: s,
                  formatTime: _formatTime,
                  onTap: () => _showSessionSheet(context, s, state.courses),
                )),

          const SizedBox(height: 28),

          // ── Upcoming Sessions ──────────────────
          if (upcomingSessions.isNotEmpty) ...[
            Text('Upcoming Sessions',
                style: AppTextTheme.displaySmall
                    .copyWith(color: context.textPrimary)),
            const SizedBox(height: 12),
            ...upcomingSessions.map((s) => _UpcomingSessionTile(
                  session: s,
                  formatTime: _formatTime,
                  onTap: () => _showSessionSheet(context, s, state.courses),
                )),
          ],

          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  void _showSessionSheet(
      BuildContext context, StudentSession session, List<EnrolledCourse> courses) {
    final course = courses.firstWhere(
      (c) => c.title == session.courseTitle,
      orElse: () => EnrolledCourse(
        id: '',
        title: session.courseTitle,
        instructorName: session.instructorName,
        category: '',
        totalSessions: 0,
        completedSessions: 0,
        progressPercent: 0,
        gradientColors: [AppColors.primary, AppColors.secondary],
        nextSessionDate: null,
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SessionSheet(
        session: session,
        course: course,
        formatTime: _formatTime,
        onViewCourse: course.id.isNotEmpty
            ? () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StudentCourseDetailScreen(course: course),
                  ),
                );
              }
            : null,
      ),
    );
  }

  // ─── Shimmer skeleton ────────────────────────────────────────
  SliverPadding _buildShimmer(BuildContext context, double hPadding) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 0),
      sliver: SliverToBoxAdapter(
        child: _HomeShimmerSkeleton(),
      ),
    );
  }
}

// ─── Session bottom sheet ────────────────────────────────────────────────────

class _SessionSheet extends StatelessWidget {
  final StudentSession session;
  final EnrolledCourse course;
  final String Function(DateTime) formatTime;
  final VoidCallback? onViewCourse;

  const _SessionSheet({
    required this.session,
    required this.course,
    required this.formatTime,
    this.onViewCourse,
  });

  @override
  Widget build(BuildContext context) {
    final isOngoing = session.status == StudentSessionStatus.ongoing;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderLight,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Gradient header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: course.gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (session.sessionNumber != null)
                    Text(
                      'Session ${session.sessionNumber}',
                      style: AppTextTheme.labelSmall.colored(Colors.white60),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    session.title ?? session.courseTitle,
                    style: AppTextTheme.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.courseTitle,
                    style: AppTextTheme.bodySmall.colored(Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _SheetRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value:
                      '${formatTime(session.startTime)} – ${formatTime(session.endTime)}',
                ),
                _SheetRow(
                  icon: session.isOnline
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  label: 'Location',
                  value: session.location,
                ),
                _SheetRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Instructor',
                  value: session.instructorName,
                ),
                _SheetRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Status',
                  valueWidget: AppBadge(
                    label: isOngoing ? 'Live' : 'Upcoming',
                    type: isOngoing ? BadgeType.ongoing : BadgeType.upcoming,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (onViewCourse != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton.icon(
                onPressed: onViewCourse,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('View Course'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _SheetRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextTheme.bodySmall.copyWith(color: context.textSecondary)),
          const Spacer(),
          valueWidget ??
              Text(value ?? '',
                  style: AppTextTheme.bodySemibold
                      .copyWith(color: context.textPrimary)),
        ],
      ),
    );
  }
}

// ─── Skeleton shimmer ────────────────────────────────────────────────────────

class _HomeShimmerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark
        ? const Color(0xFF2A2A3A)
        : const Color(0xFFE8E8F0);
    final highlightColor = context.isDark
        ? const Color(0xFF3A3A4A)
        : const Color(0xFFF5F5FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(children: [
            Expanded(child: _SkeletonStatChip()),
            const SizedBox(width: 10),
            Expanded(child: _SkeletonStatChip()),
            const SizedBox(width: 10),
            Expanded(child: _SkeletonStatChip()),
          ]),

          const SizedBox(height: 28),

          // Section title
          _SkeletonBox(width: 160, height: 18, radius: 6),
          const SizedBox(height: 14),

          // Horizontal course cards
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SkeletonCourseCard(),
                const SizedBox(width: 14),
                _SkeletonCourseCard(),
                const SizedBox(width: 14),
                _SkeletonCourseCard(),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section title
          _SkeletonBox(width: 140, height: 18, radius: 6),
          const SizedBox(height: 12),

          // Session tiles
          _SkeletonSessionTile(),
          const SizedBox(height: 10),
          _SkeletonSessionTile(),

          const SizedBox(height: 28),

          // Another section
          _SkeletonBox(width: 155, height: 18, radius: 6),
          const SizedBox(height: 12),
          _SkeletonSessionTile(),
          const SizedBox(height: 10),
          _SkeletonSessionTile(),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _SkeletonBox(
      {required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonStatChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 8),
          Container(
              width: 32,
              height: 14,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 4),
          Container(
              width: 48,
              height: 10,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }
}

class _SkeletonCourseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header placeholder
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 70,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(
                    width: 100,
                    height: 11,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(99))),
                const SizedBox(height: 6),
                Container(
                    width: 110,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonSessionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Time box
          Container(
            width: 62,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 7),
                Container(
                    width: 120,
                    height: 11,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 7),
                Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderLight),
      ),
      child: Center(
        child: Text(message,
            style: AppTextTheme.bodyMedium.colored(context.textTertiary)),
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextTheme.statValue.colored(color)),
          ),
          Text(label,
              style: AppTextTheme.statLabel
                  .copyWith(color: context.textSecondary),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final EnrolledCourse course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = course.progressPercent >= 1.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: course.gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(course.category,
                    style: AppTextTheme.labelSmall.colored(Colors.white)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppTextTheme.cardTitle
                          .copyWith(color: context.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructorName,
                      style: AppTextTheme.cardSubtitle
                          .colored(context.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text('Completed',
                                style: AppTextTheme.labelSmall
                                    .colored(AppColors.success)),
                          ],
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: course.progressPercent,
                          minHeight: 5,
                          backgroundColor: context.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              course.gradientColors.first),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(course.progressPercent * 100).toInt()}% · ${course.remainingSessions} sessions left',
                        style: AppTextTheme.labelSmall
                            .colored(context.textTertiary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final StudentSession session;
  final String Function(DateTime) formatTime;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formatTime(session.startTime),
                      style: AppTextTheme.labelMedium
                          .colored(AppColors.primary)),
                  Text(formatTime(session.endTime),
                      style: AppTextTheme.labelSmall.colored(
                          AppColors.primary.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.courseTitle,
                    style: AppTextTheme.cardTitle
                        .copyWith(color: context.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    session.instructorName,
                    style: AppTextTheme.cardSubtitle
                        .colored(context.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        session.isOnline
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        size: 13,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          session.location,
                          style: AppTextTheme.labelSmall
                              .colored(context.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (session.status == StudentSessionStatus.ongoing)
              const AppBadge(label: 'Live', type: BadgeType.ongoing)
            else
              const AppBadge(label: 'Upcoming', type: BadgeType.upcoming),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSessionTile extends StatelessWidget {
  final StudentSession session;
  final String Function(DateTime) formatTime;
  final VoidCallback onTap;

  const _UpcomingSessionTile({
    required this.session,
    required this.formatTime,
    required this.onTap,
  });

  String _relativeDay(DateTime dt) {
    final today = DateTime.now();
    final diff =
        dt.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_relativeDay(session.startTime),
                      style: AppTextTheme.labelSmall
                          .colored(AppColors.primary)),
                  Text(formatTime(session.startTime),
                      style: AppTextTheme.labelMedium
                          .colored(AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.courseTitle,
                    style: AppTextTheme.cardTitle
                        .copyWith(color: context.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        session.isOnline
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        size: 13,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          session.location,
                          style: AppTextTheme.labelSmall
                              .colored(context.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const AppBadge(label: 'Upcoming', type: BadgeType.upcoming),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
            const SizedBox(height: 16),
            Text(message,
                style: AppTextTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
