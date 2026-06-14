import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/data/models/student_session.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final EnrolledCourse course;
  const StudentCourseDetailScreen({super.key, required this.course});

  @override
  State<StudentCourseDetailScreen> createState() =>
      _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState
    extends State<StudentCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<StudentSession> _sessions = [];
  bool _sessionsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.getAllSessions(course.id),
      );
      final list = response.data ?? [];
      final sessions = list
          .map((e) => StudentSession.fromJson(
                e as Map<String, dynamic>,
                courseTitle: course.title,
                instructorName: course.instructorName,
              ))
          .toList();
      if (mounted) setState(() { _sessions = sessions; _sessionsLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _sessionsLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  EnrolledCourse get course => widget.course;

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = course.progressPercent >= 1.0;

    return Scaffold(
      backgroundColor: context.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: _headerHeight(context),
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _HeaderBackground(
                course: course,
                isCompleted: isCompleted,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: course.gradientColors.last,
                child: TabBar(
                  controller: _tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Sessions'),
                    Tab(text: 'Progress'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _SessionsTab(
              sessions: _sessions,
              isLoading: _sessionsLoading,
              formatTime: _formatTime,
              course: course,
            ),
            _ProgressTab(course: course, isCompleted: isCompleted),
          ],
        ),
      ),
    );
  }

  double _headerHeight(BuildContext context) {
    // Adapts to screen height: taller on larger screens
    final screen = MediaQuery.of(context).size.height;
    return (screen * 0.30).clamp(180.0, 260.0);
  }
}

// ─── Gradient header background ──────────────────────────────────────────────

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({
    required this.course,
    required this.isCompleted,
  });

  final EnrolledCourse course;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: course.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Category chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.category,
                  style: AppTextTheme.labelSmall.colored(Colors.white),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                course.title,
                style: AppTextTheme.displayMedium.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'by ${course.instructorName}',
                style: AppTextTheme.bodySmall
                    .colored(Colors.white.withValues(alpha: 0.8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: course.progressPercent,
                  minHeight: 7,
                  backgroundColor: Colors.white30,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${(course.progressPercent * 100).toInt()}% complete',
                    style: AppTextTheme.labelSmall
                        .colored(Colors.white.withValues(alpha: 0.85)),
                  ),
                  const Spacer(),
                  Text(
                    '${course.completedSessions}/${course.totalSessions} sessions',
                    style: AppTextTheme.labelSmall
                        .colored(Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sessions Tab ────────────────────────────────────────────────────────────

class _SessionsTab extends StatelessWidget {
  final List<StudentSession> sessions;
  final bool isLoading;
  final String Function(DateTime) formatTime;
  final EnrolledCourse course;

  const _SessionsTab({
    required this.sessions,
    required this.isLoading,
    required this.formatTime,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_note_outlined,
                  size: 32, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            Text('No sessions yet',
                style: AppTextTheme.displaySmall),
            const SizedBox(height: 6),
            Text('Sessions will appear here once scheduled.',
                style: AppTextTheme.bodySmall.colored(context.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = sessions[i];
        final isLive = s.status == StudentSessionStatus.ongoing;
        final isDone = s.status == StudentSessionStatus.completed;
        return Container(
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
              // Status icon box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success.withValues(alpha: 0.12)
                      : isLive
                          ? AppColors.error.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : isLive
                          ? Icons.play_circle_fill_rounded
                          : Icons.schedule_rounded,
                  size: 24,
                  color: isDone
                      ? AppColors.success
                      : isLive
                          ? AppColors.error
                          : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTime(s.startTime),
                      style: AppTextTheme.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          s.isOnline
                              ? Icons.videocam_outlined
                              : Icons.location_on_outlined,
                          size: 13,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            s.location,
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

              if (isLive)
                const AppBadge(label: 'Live', type: BadgeType.ongoing)
              else if (isDone)
                const AppBadge(label: 'Done', type: BadgeType.completed)
              else
                const AppBadge(label: 'Upcoming', type: BadgeType.upcoming),
            ],
          ),
        );
      },
    );
  }
}

// ─── Progress Tab ────────────────────────────────────────────────────────────

class _ProgressTab extends StatelessWidget {
  final EnrolledCourse course;
  final bool isCompleted;

  const _ProgressTab({required this.course, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final pct = (course.progressPercent * 100).toInt();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Big progress circle area
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderLight),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$pct%',
                  style: AppTextTheme.gradeHero.colored(
                    course.gradientColors.first,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('Overall Progress',
                  style: AppTextTheme.bodySmall
                      .colored(context.textSecondary)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: course.progressPercent,
                    minHeight: 10,
                    backgroundColor: context.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        course.gradientColors.first),
                  ),
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 6),
                    Text('Course Completed!',
                        style: AppTextTheme.bodySemibold
                            .colored(AppColors.success)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        _StatRow(
          label: 'Sessions Attended',
          value: '${course.completedSessions}',
          total: '${course.totalSessions}',
          progress: course.progressPercent,
          color: AppColors.primary,
        ),
        const SizedBox(height: 10),
        _StatRow(
          label: 'Sessions Remaining',
          value: '${course.remainingSessions}',
          total: '${course.totalSessions}',
          progress: 1.0 - course.progressPercent,
          color: AppColors.warning,
        ),

        if (course.nextSessionDate != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Session',
                          style: AppTextTheme.labelSmall
                              .colored(AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(
                        course.nextSessionDate!,
                        style: AppTextTheme.bodySemibold
                            .colored(AppColors.primaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Stat row ─────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String total;
  final double progress;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.total,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextTheme.bodySemibold,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                '$value / $total',
                style: AppTextTheme.bodyMedium.colored(color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: context.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
