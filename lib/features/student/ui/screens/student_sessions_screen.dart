import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';
import 'package:edu_verse/features/student/ui/cubit/student_state.dart';

class StudentSessionsScreen extends StatelessWidget {
  const StudentSessionsScreen({super.key});

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour12:$m $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _relativeDay(DateTime dt) {
    final today = DateTime.now();
    final diff =
        dt.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return '${diff.abs()}d ago';
    return 'In $diff days';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        List<StudentSession> upcoming = [];
        List<StudentSession> past = [];
        if (state is StudentLoaded) {
          upcoming = state.sessions;
          past = state.pastSessions;
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: context.bg,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradient1Start, AppColors.gradient1End],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              title: Text(
                'My Sessions',
                style: AppTextTheme.appBarTitle.colored(Colors.white),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: AppTextTheme.buttonSmall,
                    labelColor: AppColors.primary,
                    unselectedLabelStyle: AppTextTheme.buttonSmall,
                    unselectedLabelColor: Colors.white,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Past'),
                    ],
                  ),
                ),
              ),
            ),
            body: (state is StudentLoading || state is StudentInitial)
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: ShimmerList(itemCount: 5, itemHeight: 100),
                  )
                : TabBarView(
                    children: [
                      _SessionList(
                        sessions: upcoming,
                        emptyMessage: 'No upcoming sessions',
                        isPast: false,
                        formatTime: _formatTime,
                        formatDate: _formatDate,
                        relativeDay: _relativeDay,
                      ),
                      _SessionList(
                        sessions: past,
                        emptyMessage: 'No past sessions',
                        isPast: true,
                        formatTime: _formatTime,
                        formatDate: _formatDate,
                        relativeDay: _relativeDay,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SessionList extends StatelessWidget {
  final List<StudentSession> sessions;
  final String emptyMessage;
  final bool isPast;
  final String Function(DateTime) formatTime;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) relativeDay;

  const _SessionList({
    required this.sessions,
    required this.emptyMessage,
    required this.isPast,
    required this.formatTime,
    required this.formatDate,
    required this.relativeDay,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTextTheme.bodyMedium.colored(context.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _SessionCard(
        session: sessions[index],
        isPast: isPast,
        formatTime: formatTime,
        formatDate: formatDate,
        relativeDay: relativeDay,
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final StudentSession session;
  final bool isPast;
  final String Function(DateTime) formatTime;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) relativeDay;

  const _SessionCard({
    required this.session,
    required this.isPast,
    required this.formatTime,
    required this.formatDate,
    required this.relativeDay,
  });

  BadgeType get _badgeType => switch (session.status) {
    StudentSessionStatus.ongoing   => BadgeType.ongoing,
    StudentSessionStatus.upcoming  => BadgeType.upcoming,
    StudentSessionStatus.completed => BadgeType.completed,
  };

  @override
  Widget build(BuildContext context) {
    final chipColor =
        isPast ? context.borderLight : AppColors.primary.withValues(alpha: 0.12);
    final chipTextColor =
        isPast ? context.textSecondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date/time chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  relativeDay(session.startTime),
                  style: AppTextTheme.labelSmall.colored(chipTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(session.startTime),
                  style: AppTextTheme.labelMedium.colored(chipTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  formatTime(session.startTime),
                  style: AppTextTheme.labelSmall.colored(chipTextColor),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.courseTitle,
                  style: AppTextTheme.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  session.instructorName,
                  style: AppTextTheme.cardSubtitle
                      .colored(context.textSecondary),
                ),
                const SizedBox(height: 8),
                // Location chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.borderLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        session.isOnline
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        size: 12,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.location,
                        style: AppTextTheme.labelSmall
                            .colored(context.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AppBadge(
                  label: session.statusLabel,
                  type: _badgeType,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
