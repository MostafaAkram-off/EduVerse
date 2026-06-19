import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/config/di/di.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_submissions_screen.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/utils/date_formatter.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/assignment_model.dart';
import 'package:edu_verse/features/instructor/data/models/course_model.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/course_detail_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/course_detail_state.dart';
import 'package:edu_verse/features/instructor/ui/screens/instructor_session_detail_screen.dart';

class InstructorCourseDetailScreen extends StatelessWidget {
  const InstructorCourseDetailScreen({super.key, required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<InstructorCourseDetailCubit>()..loadCourseDetail(course.id),
      child: _CourseDetailView(course: course),
    );
  }
}

// ─── Main view — owns the TabController ──────────────────────

class _CourseDetailView extends StatefulWidget {
  const _CourseDetailView({required this.course});
  final CourseModel course;

  @override
  State<_CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<_CourseDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tab.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _showCreateSession() {
    final cubit = context.read<InstructorCourseDetailCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSessionSheet(
        courseId: widget.course.id,
        onCreated: () => cubit.loadCourseDetail(widget.course.id),
      ),
    );
  }

  void _showCreateAssignment() {
    final cubit = context.read<InstructorCourseDetailCubit>();
    final state = cubit.state;
    final sessions = state is InstructorCourseDetailLoaded ? state.sessions : <SessionModel>[];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateAssignmentSheet(
        sessions: sessions,
        onCreated: () => cubit.loadCourseDetail(widget.course.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _tab.index == 0 ? _showCreateSession : _showCreateAssignment,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: BlocBuilder<InstructorCourseDetailCubit, InstructorCourseDetailState>(
        builder: (context, state) {
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _CourseAppBar(course: widget.course, tabController: _tab),
            ],
            body: switch (state) {
              InstructorCourseDetailLoading() ||
              InstructorCourseDetailInitial() =>
                _buildSkeleton(context),
              InstructorCourseDetailLoaded(:final sessions, :final assignments) =>
                _buildTabs(sessions, assignments),
              InstructorCourseDetailError(:final message) => ErrorState(
                  message: message,
                  onRetry: () => context
                      .read<InstructorCourseDetailCubit>()
                      .loadCourseDetail(widget.course.id),
                ),
              _ => const SizedBox(),
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ShimmerList(itemCount: 4, itemHeight: 80),
    );
  }

  Widget _buildTabs(
    List<SessionModel> sessions,
    List<AssignmentModel> assignments,
  ) {
    return TabBarView(
      controller: _tab,
      children: [
        _SessionsTab(sessions: sessions),
        _AssignmentsTab(assignments: assignments),
      ],
    );
  }
}

// ─── SliverAppBar with gradient ─────────────────────────────

class _CourseAppBar extends StatelessWidget {
  const _CourseAppBar({required this.course, required this.tabController});

  final CourseModel course;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final isActive = course.status == CourseStatus.active;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: context.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: course.coverGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 56, 20, 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.category,
                          style: AppTextTheme.labelSmall
                              .colored(Colors.white)
                              .copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppBadge(
                        label: course.statusLabel,
                        type: isActive ? BadgeType.active : BadgeType.draft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: AppTextTheme.displaySmall
                        .colored(Colors.white)
                        .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 13, color: Colors.white.withValues(alpha: 0.80)),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentsCount} students',
                        style: AppTextTheme.labelSmall
                            .colored(Colors.white.withValues(alpha: 0.80)),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.layers_outlined,
                          size: 13, color: Colors.white.withValues(alpha: 0.80)),
                      const SizedBox(width: 4),
                      Text(
                        '${course.sessionsCount} sessions',
                        style: AppTextTheme.labelSmall
                            .colored(Colors.white.withValues(alpha: 0.80)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: ColoredBox(
          color: context.surface,
          child: TabBar(
            controller: tabController,
            labelStyle:
                AppTextTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextTheme.labelMedium,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Sessions'),
              Tab(text: 'Assignments'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sessions tab ────────────────────────────────────────────

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.sessions});

  final List<SessionModel> sessions;

  static BadgeType _badgeType(SessionStatus s) => switch (s) {
        SessionStatus.ongoing => BadgeType.ongoing,
        SessionStatus.upcoming => BadgeType.upcoming,
        SessionStatus.completed => BadgeType.completed,
      };

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return EmptyState(
        icon: Icons.event_outlined,
        title: 'No sessions yet',
        subtitle: 'Sessions for this course will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: sessions.length,
      itemBuilder: (context, i) {
        final session = sessions[i];
        return _SessionTile(
          session: session,
          badgeType: _badgeType(session.status),
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.badgeType});

  final SessionModel session;
  final BadgeType badgeType;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InstructorSessionDetailScreen(session: session),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.displayTitle,
                        style: AppTextTheme.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(label: session.statusLabel, type: badgeType),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          size: 18, color: context.textTertiary),
                      padding: EdgeInsets.zero,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 10),
                              Text('Delete Session',
                                  style: AppTextTheme.bodyMedium
                                      .colored(AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (v) {
                        if (v == 'delete') {
                          context
                              .read<InstructorCourseDetailCubit>()
                              .deleteSession(session.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: context.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatTimeRange(
                          session.startTime, session.endTime),
                      style: AppTextTheme.labelSmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      session.isOnline
                          ? Icons.videocam_rounded
                          : Icons.location_on_rounded,
                      size: 13,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.location,
                        style: AppTextTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.people_outline_rounded,
                        size: 13, color: context.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${session.studentsEnrolled}',
                      style: AppTextTheme.labelSmall,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: context.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Assignments tab ─────────────────────────────────────────

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({required this.assignments});

  final List<AssignmentModel> assignments;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_outlined,
        title: 'No assignments yet',
        subtitle: 'Assignments for this course will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: assignments.length,
      itemBuilder: (context, i) => _AssignmentCard(assignment: assignments[i]),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final AssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final pending = assignment.pendingCount;

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => InstructorSubmissionsScreen(
                assignmentId: assignment.id,
                assignmentTitle: assignment.title,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.title, style: AppTextTheme.cardTitle),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    assignment.description,
                    style: AppTextTheme.bodySmall.colored(context.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (assignment.dueDate != null) ...[
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: context.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatShortDate(assignment.dueDate!),
                        style: AppTextTheme.labelSmall
                            .colored(context.textTertiary),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (assignment.submissionsCount > 0) ...[
                      Icon(Icons.people_outline_rounded,
                          size: 12, color: context.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${assignment.gradedCount}/${assignment.submissionsCount} graded',
                        style: AppTextTheme.labelSmall
                            .colored(context.textTertiary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (pending > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pending pending',
                style: AppTextTheme.labelSmall
                    .colored(AppColors.warning)
                    .copyWith(fontSize: 11),
              ),
            )
          else if (assignment.fullyGraded)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Done',
                style: AppTextTheme.labelSmall
                    .colored(AppColors.success)
                    .copyWith(fontSize: 11),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                size: 18, color: context.textTertiary),
            padding: EdgeInsets.zero,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text('Delete Assignment',
                        style: AppTextTheme.bodyMedium
                            .colored(AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (v) {
              if (v == 'delete') {
                context
                    .read<InstructorCourseDetailCubit>()
                    .deleteAssignment(assignment.id);
              }
            },
          ),
        ],
            ),  // outer Row
                if (assignment.hasFile) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(assignment.fullFileUrl);
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
                    ),
                  ),
                ],
              ],
            ),  // Column
          ),    // Padding
        ),      // InkWell
      ),        // Material
    );          // Container
  }
}

// ─── Create Assignment bottom sheet ──────────────────────────

class _CreateAssignmentSheet extends StatefulWidget {
  const _CreateAssignmentSheet({
    required this.sessions,
    required this.onCreated,
  });

  final List<SessionModel> sessions;
  final VoidCallback onCreated;

  @override
  State<_CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends State<_CreateAssignmentSheet> {
  final _subjectCtrl  = TextEditingController();
  final _descCtrl     = TextEditingController();
  SessionModel? _selectedSession;
  DateTime? _dueDate;
  PlatformFile? _pickedFile;
  bool _isLoading     = false;
  String? _error;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    final subject = _subjectCtrl.text.trim();
    if (subject.isEmpty) {
      setState(() => _error = 'Subject is required');
      return;
    }
    if (_selectedSession == null) {
      setState(() => _error = 'Please select a session');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = GetIt.instance<Dio>();
      final fields = <String, dynamic>{
        'SessionId':   _selectedSession!.id,
        'Subject':     subject,
        'Description': _descCtrl.text.trim(),
        if (_dueDate != null) 'DueDate': _dueDate!.toIso8601String(),
      };
      if (_pickedFile != null && _pickedFile!.bytes != null) {
        fields['File'] = MultipartFile.fromBytes(
          _pickedFile!.bytes!,
          filename: _pickedFile!.name,
        );
      }
      await dio.post<dynamic>(
        ApiEndpoints.addAssignment,
        data: FormData.fromMap(fields),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
      }
    } catch (e) {
      final msg = (e is DioException)
          ? (e.response?.data?['message']?.toString() ?? 'Failed to create assignment')
          : 'Failed to create assignment';
      setState(() { _error = msg; _isLoading = false; });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Text('New Assignment', style: AppTextTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                'Add an assignment for students to complete',
                style: AppTextTheme.bodySmall.colored(context.textSecondary),
              ),
              const SizedBox(height: 20),

              // Session picker
              Text('Session *', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SessionModel>(
                    value: _selectedSession,
                    isExpanded: true,
                    hint: Text(
                      widget.sessions.isEmpty
                          ? 'No sessions available'
                          : 'Select a session',
                      style: AppTextTheme.bodyMedium.colored(context.textTertiary),
                    ),
                    style: AppTextTheme.bodyMedium.copyWith(color: context.textPrimary),
                    dropdownColor: context.surface,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: context.textTertiary),
                    items: widget.sessions.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.displayTitle.isNotEmpty
                              ? s.displayTitle
                              : DateFormatter.formatShortDate(s.startTime),
                          style: AppTextTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: widget.sessions.isEmpty
                        ? null
                        : (s) => setState(() => _selectedSession = s),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subject
              Text('Subject *', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _subjectCtrl,
                textInputAction: TextInputAction.next,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. Week 3 Assignment',
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text('Description', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                style: AppTextTheme.bodyMedium,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'What should students do?',
                ),
              ),

              const SizedBox(height: 16),

              // File attachment
              Text('Attachment (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickedFile == null ? _pickFile : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedFile != null
                          ? AppColors.primary
                          : context.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.insert_drive_file_rounded
                            : Icons.attach_file_rounded,
                        size: 18,
                        color: _pickedFile != null
                            ? AppColors.primary
                            : context.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pickedFile?.name ?? 'Attach PDF, Word, or PowerPoint',
                          style: AppTextTheme.bodyMedium.colored(
                            _pickedFile != null
                                ? context.textPrimary
                                : context.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_pickedFile != null)
                        GestureDetector(
                          onTap: () => setState(() => _pickedFile = null),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: context.textTertiary),
                        )
                      else
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: context.textTertiary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Due date
              Text('Due Date (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: context.textTertiary),
                      const SizedBox(width: 10),
                      Text(
                        _dueDate != null
                            ? DateFormatter.formatShortDate(_dueDate!)
                            : 'Select due date',
                        style: AppTextTheme.bodyMedium.colored(
                          _dueDate != null
                              ? context.textPrimary
                              : context.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: context.textTertiary),
                        ),
                    ],
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTextTheme.bodySmall.colored(AppColors.error),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: context.borderLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Create Assignment',
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

// ─── Create Session bottom sheet ─────────────────────────────

class _CreateSessionSheet extends StatefulWidget {
  const _CreateSessionSheet({
    required this.courseId,
    required this.onCreated,
  });

  final String courseId;
  final VoidCallback onCreated;

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  final _titleCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _videoUrlCtrl   = TextEditingController();
  final _extLinkCtrl    = TextEditingController();
  final _sessionNumCtrl = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _videoUrlCtrl.dispose();
    _extLinkCtrl.dispose();
    _sessionNumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = GetIt.instance<Dio>();
      final fields = <String, dynamic>{
        'CourseId':    widget.courseId,
        'Title':       title,
        'Description': _descCtrl.text.trim(),
        if (_videoUrlCtrl.text.trim().isNotEmpty)
          'VideoUrl': _videoUrlCtrl.text.trim(),
        if (_extLinkCtrl.text.trim().isNotEmpty)
          'ExternalLink': _extLinkCtrl.text.trim(),
        if (_sessionNumCtrl.text.trim().isNotEmpty)
          'SessionNumber': int.tryParse(_sessionNumCtrl.text.trim()) ?? 1,
      };
      if (_pickedFile != null && _pickedFile!.bytes != null) {
        fields['File'] = MultipartFile.fromBytes(
          _pickedFile!.bytes!,
          filename: _pickedFile!.name,
        );
      }
      await dio.post<dynamic>(
        ApiEndpoints.addSession,
        data: FormData.fromMap(fields),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
      }
    } catch (e) {
      final msg = (e is DioException)
          ? (e.response?.data?['message']?.toString() ?? 'Failed to create session')
          : 'Failed to create session';
      setState(() { _error = msg; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Text('New Session', style: AppTextTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                'Add a session to this course',
                style: AppTextTheme.bodySmall.colored(context.textSecondary),
              ),
              const SizedBox(height: 20),

              Text('Session Number', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _sessionNumCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(hintText: 'e.g. 1'),
              ),
              const SizedBox(height: 16),

              Text('Title *', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(
                    hintText: 'e.g. Introduction to Flutter'),
              ),
              const SizedBox(height: 16),

              Text('Description', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(
                    hintText: 'What will students learn?'),
              ),
              const SizedBox(height: 16),

              Text('Video URL (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _videoUrlCtrl,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(
                    hintText: 'https://youtube.com/...'),
              ),
              const SizedBox(height: 16),

              Text('External Link (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _extLinkCtrl,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                style: AppTextTheme.bodyMedium,
                decoration: const InputDecoration(
                    hintText: 'e.g. slides, repo link...'),
              ),
              const SizedBox(height: 16),

              Text('Video File (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickedFile == null ? _pickFile : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedFile != null
                          ? AppColors.primary
                          : context.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.videocam_rounded
                            : Icons.upload_file_rounded,
                        size: 18,
                        color: _pickedFile != null
                            ? AppColors.primary
                            : context.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pickedFile?.name ?? 'Upload video file',
                          style: AppTextTheme.bodyMedium.colored(
                            _pickedFile != null
                                ? context.textPrimary
                                : context.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_pickedFile != null)
                        GestureDetector(
                          onTap: () => setState(() => _pickedFile = null),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: context.textTertiary),
                        )
                      else
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: context.textTertiary),
                    ],
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: AppTextTheme.bodySmall.colored(AppColors.error)),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: context.borderLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Create Session',
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
