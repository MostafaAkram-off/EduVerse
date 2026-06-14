import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/student/features/assignments/ui/screens/upload_assignment_screen.dart';
import 'package:edu_verse/student/features/attendance/ui/screens/qr_scanner_screen.dart';
import '../../data/models/enrolled_course_model.dart';
import '../cubit/learning_cubit.dart';

String _fmtDate(String raw) {
  if (raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw;
  }
}

class _ClassroomSession {
  final String id;
  final String title;
  final double duration;
  final int sessionNumber;
  final String date;
  final String description;
  final String videoUrl;
  final String externalLink;
  final String fileUrl;
  final String attendanceCode;

  const _ClassroomSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.sessionNumber,
    required this.date,
    required this.description,
    required this.videoUrl,
    required this.externalLink,
    required this.fileUrl,
    required this.attendanceCode,
  });

  factory _ClassroomSession.fromJson(Map<String, dynamic> json) =>
      _ClassroomSession(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        duration: (json['duration'] as num?)?.toDouble() ?? 0,
        sessionNumber: json['sessionNumber'] as int? ?? 0,
        date: json['date'] as String? ?? '',
        description: json['description'] as String? ?? '',
        videoUrl: (json['videoUrl'] ?? json['link'] ?? json['url']
                ?? json['recordingUrl'] ?? json['sessionLink'] ?? '')
            .toString(),
        externalLink: (json['externalLink'] ?? json['meetingLink'] ?? '')
            .toString(),
        fileUrl: json['fileUrl'] as String? ?? '',
        attendanceCode: json['attendanceCode'] as String? ?? '',
      );

  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasExternalLink => externalLink.isNotEmpty;
  bool get hasFile => fileUrl.isNotEmpty;
  bool get hasAnyLink => hasVideo || hasExternalLink;
}

class _ClassroomAssignment {
  final String id;
  final String subject;
  final String description;
  final String date;

  const _ClassroomAssignment({
    required this.id,
    required this.subject,
    required this.description,
    required this.date,
  });

  factory _ClassroomAssignment.fromJson(Map<String, dynamic> json) =>
      _ClassroomAssignment(
        id: json['id'] as String? ?? '',
        subject: json['subject'] as String? ??
            json['title'] as String? ??
            'Assignment',
        description: json['description'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );
}

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LearningCubit>()..loadLearning(),
      child: const _LearningBody(),
    );
  }
}

class _LearningBody extends StatelessWidget {
  const _LearningBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            LearningLoading() => const _LearningShimmer(),
            LearningLoaded()  => _LearningContent(state: state),
            LearningError()   => _LearningErrorView(
              message: (state).message,
              onRetry: () => context.read<LearningCubit>().loadLearning(),
            ),
            _                 => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LOADED CONTENT
// ─────────────────────────────────────────────
class _LearningContent extends StatelessWidget {
  final LearningLoaded state;
  const _LearningContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LearningCubit>();
    final isInProgress = state.activeTab == LearningTab.inProgress;
    final courses = isInProgress ? state.inProgress : state.completed;

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Learning', style: AppTextTheme.screenTitle),
                const SizedBox(height: 16),
                // Tabs
                Row(
                  children: [
                    _Tab(
                      label: 'In Progress',
                      count: state.inProgress.length,
                      isActive: isInProgress,
                      onTap: () => cubit.switchTab(LearningTab.inProgress),
                    ),
                    _Tab(
                      label: 'Completed',
                      count: state.completed.length,
                      isActive: !isInProgress,
                      onTap: () => cubit.switchTab(LearningTab.completed),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Course List ─────────────────────
          Expanded(
            child: courses.isEmpty
                ? _EmptyLearning(
              label: isInProgress
                  ? 'No courses in progress'
                  : 'No completed courses yet',
              desc: isInProgress
                  ? 'Enroll in a course to start learning!'
                  : 'Finish a course to see it here.',
              icon: isInProgress
                  ? Icons.school_outlined
                  : Icons.emoji_events_outlined,
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: courses.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _EnrolledCourseCard(
                  enrolled: courses[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _ClassroomScreen(enrolled: courses[index]),
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
}

// ─────────────────────────────────────────────
// TAB BUTTON
// ─────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextTheme.labelLarge.copyWith(
                  color: isActive
                      ? AppColors.primary
                      : context.textSecondary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : context.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextTheme.badgeSm.copyWith(
                      color: isActive
                          ? Colors.white
                          : context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ENROLLED COURSE CARD
// ─────────────────────────────────────────────
class _EnrolledCourseCard extends StatelessWidget {
  final EnrolledCourseModel enrolled;
  final VoidCallback onTap;

  const _EnrolledCourseCard(
      {required this.enrolled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final course = enrolled.course;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            // Top color bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [course.color, course.color.withValues(alpha: 0.5)],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Course icon
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: course.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        size: 26, color: course.color),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: AppTextTheme.cardTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text('by ${course.instructor}',
                            style: AppTextTheme.cardSubtitle),
                        const SizedBox(height: 10),
                        // Progress
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value:
                                  course.progressPercent / 100,
                                  minHeight: 6,
                                  backgroundColor: context.borderLight,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      course.color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${course.progressPercent}%',
                              style:
                              AppTextTheme.progressValue.copyWith(
                                color: course.color,
                                fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CLASSROOM SCREEN
// ─────────────────────────────────────────────
class _ClassroomScreen extends StatefulWidget {
  final EnrolledCourseModel enrolled;
  const _ClassroomScreen({required this.enrolled});

  @override
  State<_ClassroomScreen> createState() =>
      _ClassroomScreenState();
}

class _ClassroomScreenState extends State<_ClassroomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_ClassroomSession>? _sessions;
  bool _sessionsLoading = true;
  List<_ClassroomAssignment>? _assignments;
  bool _assignmentsLoading = true;
  final Set<String> _submittedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
    _loadAssignments();
  }

  Future<void> _loadSessions() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.getAllSessions(widget.enrolled.course.id),
      );
      final list = response.data ?? [];
      final sessions = list
          .map((e) => _ClassroomSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
      if (mounted) setState(() { _sessions = sessions; _sessionsLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _sessions = []; _sessionsLoading = false; });
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.getAllAssignments(widget.enrolled.course.id),
      );
      final list = response.data ?? [];
      final assignments = list
          .map((e) => _ClassroomAssignment.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _assignments = assignments; _assignmentsLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _assignments = []; _assignmentsLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.enrolled.course;
    return Scaffold(
      body: Column(
        children: [
          // ── Classroom header ─────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  course.color.withValues(alpha: 0.8),
                  course.color,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(course.title,
                        style: AppTextTheme.certTitle
                            .copyWith(fontSize: 18)),
                    const SizedBox(height: 3),
                    Text('by ${course.instructor}',
                        style: AppTextTheme.certLabel.copyWith(
                            color: Colors.white70,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 14),
                    // Progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: course.progressPercent / 100,
                        minHeight: 6,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.progressPercent}% complete · ${course.duration}',
                      style: AppTextTheme.timestamp
                          .copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      indicatorColor: Colors.white,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Sessions'),
                        Tab(text: 'Assignments'),
                        Tab(text: 'Progress'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Tab content ─────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SessionsTab(
                  sessions: _sessions,
                  loading: _sessionsLoading,
                  onRetry: () {
                    setState(() { _sessions = null; _sessionsLoading = true; });
                    _loadSessions();
                  },
                ),
                _AssignmentsTab(
                  assignments: _assignments,
                  loading: _assignmentsLoading,
                  submittedIds: _submittedIds,
                  onRetry: () {
                    setState(() {
                      _assignments = null;
                      _assignmentsLoading = true;
                    });
                    _loadAssignments();
                  },
                  onSubmitted: (id) => setState(() => _submittedIds.add(id)),
                ),
                _ProgressTab(enrolled: widget.enrolled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SESSIONS TAB
// ─────────────────────────────────────────────
class _SessionsTab extends StatelessWidget {
  final List<_ClassroomSession>? sessions;
  final bool loading;
  final VoidCallback onRetry;

  const _SessionsTab({
    required this.sessions,
    required this.loading,
    required this.onRetry,
  });

  static void _showSessionDetail(
      BuildContext context, _ClassroomSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SessionDetailSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sessions == null || sessions!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined,
                  size: 48, color: context.textTertiary),
              const SizedBox(height: 12),
              const Text('No sessions available', style: AppTextTheme.bodySmall),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              'All Sessions (${sessions!.length})',
              style: AppTextTheme.bodySemibold,
            ),
            const Spacer(),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final code = await Navigator.of(context).push<String>(
                  MaterialPageRoute<String>(
                      builder: (_) => const QrScannerScreen()),
                );
                if (!context.mounted) return;
                if (code != null && code.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attendance code captured')),
                  );
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('QR Scan'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sessions!.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showSessionDetail(context, s),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${s.sessionNumber}',
                              style: AppTextTheme.bodyBold
                                  .copyWith(color: AppColors.primary, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title, style: AppTextTheme.bodySemibold),
                              if (s.date.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 12, color: context.textTertiary),
                                    const SizedBox(width: 3),
                                    Text(_fmtDate(s.date), style: AppTextTheme.timestamp),
                                  ],
                                ),
                              ],
                              if (s.duration > 0) ...[
                                const SizedBox(height: 3),
                                Text('${s.duration.toStringAsFixed(0)} min',
                                    style: AppTextTheme.timestamp),
                              ],
                            ],
                          ),
                        ),
                        if (s.hasVideo)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                size: 18, color: Colors.white),
                          )
                        else
                          Icon(Icons.chevron_right_rounded,
                              size: 22, color: context.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SESSION DETAIL SHEET
// ─────────────────────────────────────────────
class _SessionDetailSheet extends StatefulWidget {
  final _ClassroomSession session;
  const _SessionDetailSheet({required this.session});

  @override
  State<_SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<_SessionDetailSheet> {
  bool _marking = false;
  bool _marked = false;

  Future<void> _launch(String rawUrl) async {
    final url = Uri.tryParse(rawUrl);
    if (url == null) return;
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Future<void> _markCompleted() async {
    setState(() => _marking = true);
    try {
      final dio = GetIt.instance<Dio>();
      await dio.post<dynamic>(
        ApiEndpoints.markSessionCompleted(widget.session.id),
      );
      if (mounted) setState(() { _marked = true; _marking = false; });
    } catch (_) {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${s.sessionNumber}',
                      style: AppTextTheme.bodyBold
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(s.title,
                      style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (s.date.isNotEmpty) ...[
              _InfoRow(Icons.calendar_today_rounded, 'Date', _fmtDate(s.date)),
              const SizedBox(height: 8),
            ],
            if (s.duration > 0) ...[
              _InfoRow(Icons.access_time_rounded, 'Duration',
                  '${s.duration.toStringAsFixed(0)} min'),
              const SizedBox(height: 8),
            ],
            if (s.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(s.description,
                  style: AppTextTheme.bodyMedium
                      .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 16),
            if (s.hasVideo) ...[
              FilledButton.icon(
                onPressed: () => _launch(s.videoUrl),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                label: const Text('Watch Session'),
              ),
              const SizedBox(height: 10),
            ],
            if (s.hasExternalLink) ...[
              OutlinedButton.icon(
                onPressed: () => _launch(s.externalLink),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('External Resources'),
              ),
              const SizedBox(height: 10),
            ],
            if (_marked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text('Session marked as completed',
                        style: TextStyle(color: AppColors.success)),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _marking ? null : _markCompleted,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _marking
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: const Text('Mark as Completed'),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textTertiary),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextTheme.bodySmall),
        Text(value, style: AppTextTheme.bodySemibold),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ASSIGNMENTS TAB
// ─────────────────────────────────────────────
class _AssignmentsTab extends StatelessWidget {
  final List<_ClassroomAssignment>? assignments;
  final bool loading;
  final Set<String> submittedIds;
  final VoidCallback onRetry;
  final void Function(String id) onSubmitted;

  const _AssignmentsTab({
    required this.assignments,
    required this.loading,
    required this.submittedIds,
    required this.onRetry,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (assignments == null || assignments!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 48, color: context.textTertiary),
              const SizedBox(height: 12),
              const Text('No assignments yet', style: AppTextTheme.bodySmall),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: assignments!.map((a) {
        final isSubmitted = submittedIds.contains(a.id);
        final status = isSubmitted ? 'submitted' : 'pending';
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isSubmitted
                ? null
                : () async {
                    final submitted =
                        await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => UploadAssignmentScreen(
                          assignmentId: a.id,
                          title: a.subject,
                          description: a.description,
                          dueDate: a.date,
                        ),
                      ),
                    );
                    if (submitted == true) onSubmitted(a.id);
                  },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.subject, style: AppTextTheme.cardTitle),
                        if (a.date.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text('Due: ${_fmtDate(a.date)}',
                              style: AppTextTheme.timestamp),
                        ],
                        const SizedBox(height: 8),
                        _StatusBadge(status: status),
                      ],
                    ),
                  ),
                  if (!isSubmitted)
                    const Icon(Icons.upload_file_rounded,
                        size: 20, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESS TAB
// ─────────────────────────────────────────────
class _ProgressTab extends StatelessWidget {
  final EnrolledCourseModel enrolled;
  const _ProgressTab({required this.enrolled});

  @override
  Widget build(BuildContext context) {
    final course = enrolled.course;
    final items = [
      _ProgressItem(
        label: 'Sessions Attended',
        value: enrolled.attendedSessions,
        total: enrolled.totalSessions,
        color: AppColors.primary,
      ),
      _ProgressItem(
        label: 'Assignments Done',
        value: enrolled.assignments
            .where((a) => a.status != 'pending')
            .length,
        total: enrolled.assignments.length,
        color: AppColors.success,
      ),
      _ProgressItem(
        label: 'Overall Progress',
        value: course.progressPercent,
        total: 100,
        color: course.color,
        isPercent: true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Big progress circle
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderLight),
          ),
          child: Column(
            children: [
              Text(
                '${course.progressPercent}%',
                style: AppTextTheme.gradeHero
                    .copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text('Overall Progress',
                  style: AppTextTheme.bodySmall),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: course.progressPercent / 100,
                    minHeight: 10,
                    backgroundColor: context.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
              (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label,
                        style: AppTextTheme.bodySemibold),
                    Text(
                      item.isPercent
                          ? '${item.value}%'
                          : '${item.value}/${item.total}',
                      style: AppTextTheme.progressValue
                          .copyWith(color: item.color),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.total > 0 ? item.value / item.total : 0.0,
                    minHeight: 7,
                    backgroundColor: context.borderLight,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(item.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressItem {
  final String label;
  final int value;
  final int total;
  final Color color;
  final bool isPercent;

  const _ProgressItem({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    this.isPercent = false,
  });
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _fg => switch (status) {
    'graded' || 'completed' => AppColors.success,
    'submitted' || 'live'   => AppColors.primary,
    _                       => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final bg = _fg.withValues(alpha: context.isDark ? 0.2 : 0.12);
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style:
        AppTextTheme.badgeSm.copyWith(color: _fg, fontSize: 10),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyLearning extends StatelessWidget {
  final String label;
  final String desc;
  final IconData icon;
  const _EmptyLearning(
      {required this.label,
        required this.desc,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(label, style: AppTextTheme.displaySmall),
            const SizedBox(height: 8),
            Text(desc,
                style: AppTextTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────
class _LearningShimmer extends StatelessWidget {
  const _LearningShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: context.surface,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _S(width: 180, height: 22),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _S(height: 40)),
                const SizedBox(width: 12),
                Expanded(child: _S(height: 40)),
              ]),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _S(width: double.infinity, height: 110, r: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _S extends StatelessWidget {
  final double? width;
  final double height;
  final double r;

  const _S({this.width, required this.height, this.r = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.borderLight,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────
class _LearningErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LearningErrorView(
      {required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text('Something went wrong',
                style: AppTextTheme.displaySmall),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}