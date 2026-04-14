import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/utils/date_formatter.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/app_stat_card.dart';

import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorHomeScreen extends StatelessWidget {
  const InstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorCubit, InstructorState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: switch (state) {
            InstructorLoading() || InstructorInitial() => _LoadingSkeleton(),
            InstructorLoaded() =>
              _HomeBody(state: state),
            InstructorError(:final message) => ErrorState(
                message: message,
                onRetry: () =>
                    context.read<InstructorCubit>().loadData(),
              ),
            _ => const SizedBox(),
          },
        );
      },
    );
  }
}

// ─── Loaded body ──────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});
  final InstructorLoaded state;

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: _GradientHeader(greeting: greeting),
            collapseMode: CollapseMode.pin,
          ),
          actions: [
            _NotificationBell(),
            const SizedBox(width: 8),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Stats grid ───────────────────────────────
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                children: [
                  AppStatCard(
                    label: 'Total Students',
                    value: '${state.stats.totalStudents}',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                    trend: state.stats.studentsTrend,
                    trendUp: true,
                  ),
                  AppStatCard(
                    label: 'Active Courses',
                    value: '${state.stats.activeCourses}',
                    icon: Icons.book_rounded,
                    color: AppColors.secondary,
                  ),
                  AppStatCard(
                    label: 'Sessions Today',
                    value: '${state.stats.sessionsToday}',
                    icon: Icons.today_rounded,
                    color: AppColors.warning,
                  ),
                  AppStatCard(
                    label: 'Completion',
                    value:
                        '${(state.stats.completionRate * 100).toStringAsFixed(0)}%',
                    icon: Icons.verified_rounded,
                    color: AppColors.success,
                    trend: state.stats.completionTrend,
                    trendUp: true,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Today's sessions ─────────────────────────
              if (state.todaySessions.isNotEmpty) ...[
                _SectionHeader(
                  title: "Today's Sessions",
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.todaySessions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        _SessionCard(session: state.todaySessions[i]),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // ── Upcoming sessions ────────────────────────
              if (state.upcomingSessions.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Upcoming',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                ...state.upcomingSessions.take(3).map(
                    (s) => _UpcomingTile(session: s)),
                const SizedBox(height: 24),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ─── Gradient header ──────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradient1Start, AppColors.gradient1End],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(greeting,
                  style: AppTextTheme.greeting
                      .colored(Colors.white.withValues(alpha: 0.85))),
              const SizedBox(height: 2),
              Text('Ahmed Hassan',
                  style: AppTextTheme.greetingName
                      .colored(Colors.white)
                      .copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(DateFormatter.formatDayMonth(DateTime.now()),
                  style: AppTextTheme.bodySmall
                      .colored(Colors.white.withValues(alpha: 0.75))),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notification bell ────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 22),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextTheme.displaySmall),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
            ),
            child: Text('See all',
                style: AppTextTheme.labelMedium
                    .colored(AppColors.primary)),
          ),
      ],
    );
  }
}

// ─── Today's session card (horizontal) ───────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final SessionModel session;

  static BadgeType _badgeType(SessionStatus s) => switch (s) {
        SessionStatus.ongoing   => BadgeType.ongoing,
        SessionStatus.upcoming  => BadgeType.upcoming,
        SessionStatus.completed => BadgeType.completed,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBadge(
                label: session.statusLabel,
                type: _badgeType(session.status),
              ),
              Icon(
                session.isOnline
                    ? Icons.videocam_rounded
                    : Icons.location_on_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const Spacer(),
          Text(session.courseTitle,
              style: AppTextTheme.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatTimeRange(
                    session.startTime, session.endTime),
                style: AppTextTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${session.studentsEnrolled} students',
                  style: AppTextTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming session tile ────────────────────────────────────

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.session});
  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormatter.formatTime(session.startTime)
                      .split(' ')[0],
                  style: AppTextTheme.labelMedium.colored(AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                Text(
                  DateFormatter.formatTime(session.startTime)
                      .split(' ')[1],
                  style: AppTextTheme.labelSmall.colored(AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.courseTitle,
                    style: AppTextTheme.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      session.isOnline
                          ? Icons.videocam_outlined
                          : Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      session.isOnline ? session.location : session.location,
                      style: AppTextTheme.labelSmall,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people_outline_rounded,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text('${session.studentsEnrolled}',
                        style: AppTextTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          Text(DateFormatter.relativeDay(session.startTime),
              style: AppTextTheme.labelSmall.colored(AppColors.primary)),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          backgroundColor: AppColors.background,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.shimmerBase,
                    AppColors.shimmerHighlight,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                ShimmerGrid(crossAxisCount: 2, itemCount: 4),
                const SizedBox(height: 28),
                ShimmerList(itemCount: 3, itemHeight: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
