import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/utils/date_formatter.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorSessionsScreen extends StatelessWidget {
  const InstructorSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorCubit, InstructorState>(
      builder: (context, state) => Scaffold(
        backgroundColor: context.bg,
        body: switch (state) {
          InstructorLoading() || InstructorInitial() => _Skeleton(),
          InstructorLoaded(:final todaySessions, :final upcomingSessions) =>
            _Body(today: todaySessions, upcoming: upcomingSessions),
          InstructorError(:final message) => ErrorState(
              message: message,
              onRetry: () => context.read<InstructorCubit>().loadData(),
            ),
          _ => const SizedBox(),
        },
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.today, required this.upcoming});

  final List<SessionModel> today;
  final List<SessionModel> upcoming;

  @override
  Widget build(BuildContext context) {
    final isEmpty = today.isEmpty && upcoming.isEmpty;

    return CustomScrollView(
      slivers: [
        // ── App bar ───────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: Text('Sessions', style: AppTextTheme.screenTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_month_rounded,
                  color: context.textPrimary),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calendar view coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        if (isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No Sessions',
              subtitle: 'Sessions will appear here once scheduled.',
            ),
          )
        else ...[
          // ── Today's sessions ─────────────────────────────
          if (today.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionLabel(
                label: "Today  •  ${DateFormatter.formatDayMonth(DateTime.now())}",
                count: today.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _SessionTile(
                    session: today[i],
                    isLast: i == today.length - 1,
                    showTimeline: true,
                  ),
                  childCount: today.length,
                ),
              ),
            ),
          ],

          // ── Upcoming ──────────────────────────────────────
          if (upcoming.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionLabel(
                label: 'Upcoming',
                count: upcoming.length,
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _SessionTile(
                    session: upcoming[i],
                    isLast: i == upcoming.length - 1,
                    showTimeline: true,
                  ),
                  childCount: upcoming.length,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(label,
              style: AppTextTheme.displaySmall),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style:
                    AppTextTheme.labelSmall.colored(AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ─── Session tile (timeline style) ───────────────────────────

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isLast,
    this.showTimeline = false,
  });

  final SessionModel session;
  final bool isLast;
  final bool showTimeline;

  static BadgeType _badgeType(SessionStatus s) => switch (s) {
        SessionStatus.ongoing   => BadgeType.ongoing,
        SessionStatus.upcoming  => BadgeType.upcoming,
        SessionStatus.completed => BadgeType.completed,
      };

  static Color _statusColor(SessionStatus s) => switch (s) {
        SessionStatus.ongoing   => AppColors.primary,
        SessionStatus.upcoming  => AppColors.warning,
        SessionStatus.completed => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(session.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          if (showTimeline)
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: context.bg, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: context.borderLight,
                      ),
                    ),
                ],
              ),
            ),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showSessionDetail(context, session),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                session.courseTitle,
                                style: AppTextTheme.cardTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppBadge(
                              label: session.statusLabel,
                              type: _badgeType(session.status),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Meta row
                        Row(
                          children: [
                            _MetaChip(
                              icon: Icons.access_time_rounded,
                              label: DateFormatter.formatTimeRange(
                                  session.startTime, session.endTime),
                            ),
                            const SizedBox(width: 10),
                            _MetaChip(
                              icon: session.isOnline
                                  ? Icons.videocam_rounded
                                  : Icons.location_on_rounded,
                              label: session.location,
                            ),
                            const Spacer(),
                            _MetaChip(
                              icon: Icons.people_outline_rounded,
                              label:
                                  '${session.studentsEnrolled}',
                            ),
                          ],
                        ),

                        if (session.status == SessionStatus.ongoing) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('Session in progress',
                                    style: AppTextTheme.labelSmall
                                        .colored(Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(BuildContext context, SessionModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(s.courseTitle,
                        style: AppTextTheme.displaySmall),
                  ),
                  AppBadge(
                    label: s.statusLabel,
                    type: _badgeType(s.status),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.access_time_rounded,
                label: DateFormatter.formatTimeRange(s.startTime, s.endTime),
              ),
              _DetailRow(
                icon: s.isOnline ? Icons.videocam_rounded : Icons.location_on_rounded,
                label: s.location,
              ),
              _DetailRow(
                icon: Icons.people_outline_rounded,
                label: '${s.studentsEnrolled} students enrolled',
              ),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: DateFormatter.formatDayMonth(s.startTime),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: context.primary),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextTheme.bodySemibold),
        ],
      ),
    );
  }
}

// ─── Meta chip ────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTextTheme.labelSmall),
      ],
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: context.bg,
          elevation: 0,
          title: Text('Sessions', style: AppTextTheme.screenTitle),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
              child: ShimmerList(itemCount: 5, itemHeight: 100)),
        ),
      ],
    );
  }
}
