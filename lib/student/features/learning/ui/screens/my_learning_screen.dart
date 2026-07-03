import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_verse/api/attendance/attendance_api_service.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/video_player_screen.dart';
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
  final bool isCompleted;

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
    this.isCompleted = false,
  });

  factory _ClassroomSession.fromJson(Map<String, dynamic> json) {
    // Normalise a raw value — strip null-string and blank values
    String str(dynamic v) {
      final s = (v ?? '').toString().trim();
      return (s == 'null') ? '' : s;
    }

    final videoUrl = str(
      json['videoUrl'] ??
      json['video_url'] ??
      json['videoLink'] ??
      json['recordingUrl'] ??
      json['sessionVideoUrl'] ??
      json['recordUrl'],
    );

    // External link — prefer explicit field; fall back to generic link/url
    // only when there is no dedicated video URL so they don't overlap.
    final rawExternal = str(
      json['externalLink'] ??
      json['external_link'] ??
      json['meetingLink'] ??
      json['meeting_link'],
    );
    final externalLink = rawExternal.isNotEmpty
        ? rawExternal
        : (videoUrl.isEmpty
            ? str(json['link'] ?? json['url'] ?? json['sessionLink'])
            : '');

    return _ClassroomSession(
      id: str(json['id'] ?? json['sessionId']),
      title: str(json['title'] ?? json['sessionTitle'] ?? json['name']),
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      sessionNumber: (json['sessionNumber'] as num?)?.toInt() ??
          (json['session_number'] as num?)?.toInt() ?? 0,
      date: str(json['date'] ?? json['sessionDate'] ?? json['startDate']),
      description: str(json['description'] ?? json['summary']),
      videoUrl: videoUrl,
      externalLink: externalLink,
      fileUrl: str(json['fileUrl'] ?? json['file_url'] ?? json['materialUrl']),
      attendanceCode: str(json['attendanceCode'] ?? json['attendance_code']),
      isCompleted: (json['isCompleted'] as bool?) ??
          (json['is_completed'] as bool?) ??
          false,
    );
  }

  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasFile => fileUrl.isNotEmpty;
  bool get hasExternalLink => externalLink.isNotEmpty;
  bool get hasContent => hasVideo || hasFile || hasExternalLink;

  /// Full URL to stream/download the session material from Azure Blob.
  String get fullFileUrl =>
      '${ApiEndpoints.baseUrl}/Cloud/Get/sessions/$fileUrl';
}

class _ClassroomAssignment {
  final String id;
  final String subject;
  final String description;
  final String date;
  final String fileUrl;

  const _ClassroomAssignment({
    required this.id,
    required this.subject,
    required this.description,
    required this.date,
    this.fileUrl = '',
  });

  factory _ClassroomAssignment.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) {
      final s = (v ?? '').toString().trim();
      return s == 'null' ? '' : s;
    }
    return _ClassroomAssignment(
      id:          str(json['id']),
      subject:     str(json['subject'] ?? json['title'] ?? 'Assignment'),
      description: str(json['description']),
      date:        str(json['dueDate'] ?? json['due_date'] ?? json['date']),
      fileUrl:     str(json['fileUrl'] ?? json['file_url'] ?? json['materialUrl']),
    );
  }

  bool get hasFile => fileUrl.isNotEmpty;
  String get fullFileUrl =>
      '${ApiEndpoints.baseUrl}/Cloud/Get/assignments/$fileUrl';
}

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  late final LearningCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<LearningCubit>()..loadLearning();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
                  // Course thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: course.imageUrl != null &&
                              course.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: course.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _ThumbPlaceholder(
                                  color: course.color),
                              errorWidget: (_, __, ___) =>
                                  _ThumbPlaceholder(color: course.color),
                            )
                          : _ThumbPlaceholder(color: course.color),
                    ),
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
                        if (course.instructor.isNotEmpty)
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

class _ThumbPlaceholder extends StatelessWidget {
  final Color color;
  const _ThumbPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.8), color],
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 28, color: Colors.white),
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

  // Local progress — updated immediately when sessions are toggled.
  late int _progressPercent;
  final Set<String> _completedIds = {};
  bool _completionDataLoaded = false;
  // null = not loaded yet, true/false = server answer
  bool? _eligibleFromApi;

  @override
  void initState() {
    super.initState();
    _progressPercent = widget.enrolled.course.progressPercent;
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
    _loadAssignments();
    _loadProgress();
    _loadEligibility();
    _loadAssignmentProgress();
  }

  void _onSessionToggled(String id, bool isNowCompleted) {
    if (isNowCompleted) {
      _completedIds.add(id);
    } else {
      _completedIds.remove(id);
    }
    final total = _sessions?.length ?? 0;
    if (total == 0) return;

    int newPercent;
    if (_completionDataLoaded) {
      newPercent = (_completedIds.length * 100 / total).round();
    } else {
      final delta = (100 / total).round();
      newPercent = (_progressPercent + (isNowCompleted ? delta : -delta))
          .clamp(0, 100);
      _completionDataLoaded = true;
    }

    setState(() => _progressPercent = newPercent);

    // Persist the new progress to the server via the working endpoint.
    _syncProgress(newPercent);
  }

  void _syncProgress(int percent) {
    final courseId = widget.enrolled.course.id;
    if (courseId.isEmpty) return;
    GetIt.instance<Dio>().put<dynamic>(
      ApiEndpoints.updateProgress,
      data: {
        'courseId': courseId,
        'email': AuthSession.email,
        'progressionValue': percent,
      },
    ).ignore();
  }

  Future<void> _loadSessions() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<dynamic>(
        ApiEndpoints.getAllSessions(widget.enrolled.course.id),
      );
      final raw = response.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['sessions'] ?? <dynamic>[]) as List)
              : <dynamic>[];
      final sessions = list
          .map((e) => _ClassroomSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _sessionsLoading = false;
          // Only use isCompleted from sessions if the API actually returns it
          // (at least one session flagged true). Otherwise keep the progressPercent
          // that came from the enrolled-courses API, which the backend computes server-side.
          final completedFromApi =
              sessions.where((s) => s.isCompleted).toList();
          if (completedFromApi.isNotEmpty) {
            _completedIds
              ..clear()
              ..addAll(completedFromApi.map((s) => s.id));
            _progressPercent =
                (_completedIds.length * 100 / sessions.length).round();
            _completionDataLoaded = true;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() { _sessions = []; _sessionsLoading = false; });
    }
  }

  // Fetches per-session completion status from the progress endpoint so that
  // _completedIds is populated even when GetAllSessions doesn't carry isCompleted.
  Future<void> _loadProgress() async {
    try {
      final dio = GetIt.instance<Dio>();
      final resp = await dio.get<dynamic>(
        ApiEndpoints.progressCourse(widget.enrolled.course.id),
      );
      final raw = resp.data;
      if (raw is! Map) return;

      // Try to extract completed session IDs from various field names the
      // backend might use.
      final dynamic idList =
          raw['completedSessionIds'] ??
          raw['completedSessions'] ??
          raw['sessionIds'] ??
          raw['sessions'];

      if (idList is List && idList.isNotEmpty) {
        final ids = idList.map((e) => e.toString()).toSet();
        if (mounted) {
          setState(() {
            _completedIds
              ..clear()
              ..addAll(ids);
            _completionDataLoaded = true;
            final total = _sessions?.length ?? 0;
            if (total > 0) {
              _progressPercent =
                  (_completedIds.length * 100 / total).round();
            }
          });
        }
        return;
      }

      // If the endpoint only returns a percent (no id list), use it
      // as long as we haven't already got real id data.
      if (!_completionDataLoaded) {
        final pct = (raw['progression'] ??
                raw['progressPercent'] ??
                raw['progress'] ??
                raw['percent']) as num?;
        if (pct != null && mounted) {
          setState(() => _progressPercent = pct.toInt());
        }
      }
    } catch (_) {
      // Non-fatal — keep whatever value we have from enrolled courses.
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<dynamic>(
        ApiEndpoints.getAllAssignments(widget.enrolled.course.id),
      );
      final raw = response.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['assignments'] ?? <dynamic>[]) as List)
              : <dynamic>[];
      final assignments = list
          .map((e) => _ClassroomAssignment.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _assignments = assignments; _assignmentsLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _assignments = []; _assignmentsLoading = false; });
    }
  }

  Future<void> _loadEligibility() async {
    final courseId = widget.enrolled.course.id;
    if (courseId.isEmpty) return;
    try {
      final dio = GetIt.instance<Dio>();
      final resp = await dio.get<dynamic>(
        ApiEndpoints.certificateEligibility(courseId),
      );
      final raw = resp.data;
      bool? eligible;
      if (raw is bool) {
        eligible = raw;
      } else if (raw is Map) {
        eligible = (raw['eligible'] ?? raw['isEligible'] ?? raw['result']) as bool?;
      }
      if (eligible != null && mounted) {
        setState(() => _eligibleFromApi = eligible);
      }
    } catch (_) {
      // Non-fatal — fall back to local calculation in _ProgressTab.
    }
  }

  Future<void> _loadAssignmentProgress() async {
    final courseId = widget.enrolled.course.id;
    if (courseId.isEmpty) return;
    try {
      final dio = GetIt.instance<Dio>();
      final resp = await dio.get<dynamic>(
        ApiEndpoints.assignmentProgress(courseId),
      );
      final raw = resp.data;
      if (raw is! Map) return;
      // Extract submitted assignment IDs if the server returns them.
      final dynamic idList =
          raw['submittedIds'] ?? raw['submittedAssignmentIds'] ?? raw['ids'];
      if (idList is List && idList.isNotEmpty && mounted) {
        setState(() {
          _submittedIds.addAll(idList.map((e) => e.toString()));
        });
      }
    } catch (_) {
      // Non-fatal — local optimistic state remains.
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
                    if (course.instructor.isNotEmpty)
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
                        value: _progressPercent / 100,
                        minHeight: 6,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_progressPercent% complete · ${course.duration}',
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
                  onSessionToggled: _onSessionToggled,
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
                _ProgressTab(
                  enrolled: widget.enrolled,
                  progressPercent: _progressPercent,
                  sessions: _sessions,
                  assignments: _assignments,
                  submittedIds: _submittedIds,
                  eligibleFromApi: _eligibleFromApi,
                ),
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
  final void Function(String id, bool isNowCompleted)? onSessionToggled;

  const _SessionsTab({
    required this.sessions,
    required this.loading,
    required this.onRetry,
    this.onSessionToggled,
  });

  void _showSessionDetail(BuildContext context, _ClassroomSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SessionDetailSheet(
        session: session,
        onToggled: onSessionToggled,
      ),
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
                        if (s.hasContent)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              s.hasVideo || s.hasFile
                                  ? Icons.play_arrow_rounded
                                  : Icons.open_in_new_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
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
  final void Function(String id, bool isNowCompleted)? onToggled;
  const _SessionDetailSheet({required this.session, this.onToggled});

  @override
  State<_SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<_SessionDetailSheet> {
  bool _marking = false;
  late bool _marked;

  @override
  void initState() {
    super.initState();
    _marked = widget.session.isCompleted;
  }

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

  Future<void> _toggleCompleted() async {
    // Optimistic update — flip state immediately so the UI responds at once.
    final newState = !_marked;
    setState(() { _marked = newState; _marking = false; });
    widget.onToggled?.call(widget.session.id, newState);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Session marked as completed' : 'Marked as incomplete'),
          duration: const Duration(seconds: 2),
          backgroundColor: newState ? Colors.green.shade700 : null,
        ),
      );
    }

    // Toggle session completion on the server via the Progress endpoint.
    try {
      final dio = GetIt.instance<Dio>();
      await dio.post<dynamic>(
        ApiEndpoints.toggleSessionDone(widget.session.id),
      );
    } catch (_) {
      // Non-fatal — progress is also synced via PUT /User/updateprogress.
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
            if (s.hasContent) ...[
              FilledButton.icon(
                onPressed: () {
                  if (s.hasVideo) {
                    _launch(s.videoUrl);
                  } else if (s.hasFile) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        url: s.fullFileUrl,
                        title: s.title,
                      ),
                    ));
                  } else {
                    _launch(s.externalLink);
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(
                  s.hasVideo || s.hasFile
                      ? Icons.play_circle_outline_rounded
                      : Icons.open_in_new_rounded,
                  size: 20,
                ),
                label: Text(
                  s.hasExternalLink && !s.hasVideo && !s.hasFile
                      ? 'Open Resources'
                      : 'Watch Session',
                ),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: _marking ? null : _toggleCompleted,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: _marked ? AppColors.success : null,
                side: _marked
                    ? const BorderSide(color: AppColors.success)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: _marking
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _marked ? AppColors.success : null,
                      ),
                    )
                  : Icon(
                      _marked
                          ? Icons.check_circle_rounded
                          : Icons.check_rounded,
                      size: 18,
                    ),
              label: Text(
                _marked ? 'Completed · Tap to undo' : 'Mark as Completed',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => QrScannerScreen(
                      sessionName: s.title,
                      sessionTime: s.date.isNotEmpty ? _fmtDate(s.date) : null,
                    ),
                  ),
                );
                if (result != null && context.mounted) {
                  try {
                    await GetIt.instance<AttendanceApiService>()
                        .markAttendance(s.id, result);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Attendance marked successfully')),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not mark attendance')),
                      );
                    }
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan QR to Attend'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  if (a.hasFile) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(a.fullFileUrl);
                        if (!await launchUrl(uri,
                            mode: LaunchMode.externalApplication)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not open file')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.insert_drive_file_outlined,
                          size: 16),
                      label: const Text('View Assignment File'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: AppTextTheme.labelSmall,
                      ),
                    ),
                  ],
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
class _ProgressTab extends StatefulWidget {
  final EnrolledCourseModel enrolled;
  final int progressPercent;
  final List<_ClassroomSession>? sessions;
  final List<_ClassroomAssignment>? assignments;
  final Set<String> submittedIds;
  final bool? eligibleFromApi;

  const _ProgressTab({
    required this.enrolled,
    required this.progressPercent,
    required this.sessions,
    required this.assignments,
    required this.submittedIds,
    this.eligibleFromApi,
  });

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  bool _generating = false;
  bool _generated = false;
  String? _certError;

  Future<void> _generateCertificate() async {
    setState(() { _generating = true; _certError = null; });
    try {
      final dio = GetIt.instance<Dio>();
      await dio.post<dynamic>(
        ApiEndpoints.generateCertificate(widget.enrolled.course.id),
      );
      if (mounted) setState(() { _generated = true; _generating = false; });
    } catch (e) {
      final msg = (e is DioException)
          ? (e.response?.data?['message']?.toString() ??
              e.response?.data?.toString() ??
              'Not eligible yet')
          : 'Failed to generate certificate';
      if (mounted) setState(() { _certError = msg; _generating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.enrolled.course;
    final totalSessions = widget.sessions?.length ?? 0;
    final totalAssignments = widget.assignments?.length ?? 0;
    final doneAssignments = widget.submittedIds.length;
    final assignmentPct = totalAssignments > 0
        ? (doneAssignments / totalAssignments * 100).round()
        : 0;
    final eligible = widget.eligibleFromApi ??
        (totalAssignments > 0 && assignmentPct >= 80);

    final items = [
      if (totalSessions > 0)
        _ProgressItem(
          label: 'Sessions Attended',
          value: widget.enrolled.attendedSessions,
          total: totalSessions,
          color: AppColors.primary,
        ),
      if (totalAssignments > 0)
        _ProgressItem(
          label: 'Assignments Submitted',
          value: doneAssignments,
          total: totalAssignments,
          color: AppColors.success,
        ),
      _ProgressItem(
        label: 'Overall Progress',
        value: widget.progressPercent,
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
                '${widget.progressPercent}%',
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
                    value: widget.progressPercent / 100,
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

        const SizedBox(height: 6),

        // Certificate section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: eligible
                  ? AppColors.success.withValues(alpha: 0.4)
                  : context.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: eligible ? AppColors.success : context.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text('Certificate',
                      style: AppTextTheme.bodySemibold),
                ],
              ),
              const SizedBox(height: 10),
              // Requirement row
              _RequirementRow(
                label: 'Submit ≥ 80% of assignments',
                met: eligible,
                detail: totalAssignments > 0
                    ? '$assignmentPct% ($doneAssignments/$totalAssignments)'
                    : 'No assignments',
              ),
              const SizedBox(height: 6),
              _RequirementRow(
                label: 'Complete course duration',
                met: null,
                detail: 'Checked by server',
              ),
              const SizedBox(height: 14),
              if (_certError != null) ...[
                Text(
                  _certError!,
                  style: AppTextTheme.bodySmall.colored(AppColors.error),
                ),
                const SizedBox(height: 10),
              ],
              if (_generated)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Text('Certificate generated!',
                          style: AppTextTheme.bodySemibold
                              .colored(AppColors.success)),
                    ],
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: _generating ? null : _generateCertificate,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: eligible
                        ? AppColors.success
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _generating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Get Certificate'),
                ),
            ],
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

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.met,
    required this.detail,
  });

  final String label;
  final bool? met; // null = unknown (server-side check)
  final String detail;

  @override
  Widget build(BuildContext context) {
    final color = met == null
        ? AppColors.warning
        : met!
            ? AppColors.success
            : context.textSecondary;
    final icon = met == null
        ? Icons.schedule_rounded
        : met!
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTextTheme.bodySmall),
        ),
        Text(detail,
            style: AppTextTheme.labelSmall.colored(color)),
      ],
    );
  }
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