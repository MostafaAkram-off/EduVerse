import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/config/di/di.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/utils/date_formatter.dart';
import 'package:edu_verse/core/widgets/app_avatar.dart';
import 'package:edu_verse/core/widgets/app_chip.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/submission_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/submissions_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/submissions_state.dart';

class InstructorSubmissionsScreen extends StatelessWidget {
  const InstructorSubmissionsScreen({
    super.key,
    this.assignmentId,
    this.assignmentTitle,
  });

  /// When set, only submissions for this assignment are shown.
  final String? assignmentId;
  final String? assignmentTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InstructorSubmissionsCubit>()..loadSubmissions(),
      child: _SubmissionsView(
        assignmentId: assignmentId,
        assignmentTitle: assignmentTitle,
      ),
    );
  }
}

class _SubmissionsView extends StatefulWidget {
  const _SubmissionsView({this.assignmentId, this.assignmentTitle});

  final String? assignmentId;
  final String? assignmentTitle;

  @override
  State<_SubmissionsView> createState() => _SubmissionsViewState();
}

class _SubmissionsViewState extends State<_SubmissionsView> {
  int _filterIndex = 0; // 0=All, 1=Pending, 2=Graded
  static const _filters = ['All', 'Pending', 'Graded'];

  List<SubmissionModel> _applyFilter(List<SubmissionModel> all) {
    // If navigated from an assignment card, pre-filter by assignment
    final byAssignment = widget.assignmentId == null
        ? all
        : all.where((s) => s.assignmentId == widget.assignmentId).toList();
    return switch (_filterIndex) {
      1 => byAssignment.where((s) => !s.isGraded).toList(),
      2 => byAssignment.where((s) => s.isGraded).toList(),
      _ => byAssignment,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorSubmissionsCubit, InstructorSubmissionsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.bg,
          body: switch (state) {
            InstructorSubmissionsLoading() ||
            InstructorSubmissionsInitial() =>
              _buildSkeleton(context),
            InstructorSubmissionsLoaded(:final submissions, :final isGrading) =>
              _buildBody(context, submissions, isGrading),
            InstructorSubmissionsError(:final message) =>
              _buildError(context, message),
            _ => const SizedBox(),
          },
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Assignment Reviews', style: AppTextTheme.screenTitle),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: ShimmerList(itemCount: 4, itemHeight: 90),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        title: Text('Assignment Reviews', style: AppTextTheme.screenTitle),
      ),
      body: Center(
        child: Text(message, style: AppTextTheme.bodyMedium.colored(context.textSecondary)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<SubmissionModel> allSubmissions,
    bool isGrading,
  ) {
    final filtered = _applyFilter(allSubmissions);
    final pendingCount = allSubmissions.where((s) => !s.isGraded).length;

    return CustomScrollView(
      slivers: [
        // ── AppBar ───────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          // Show back button only when navigated from an assignment card
          automaticallyImplyLeading: widget.assignmentId != null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.assignmentTitle != null
                        ? 'Submissions'
                        : 'Assignment Reviews',
                    style: AppTextTheme.screenTitle,
                  ),
                  const SizedBox(width: 10),
                  if (pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pendingCount pending',
                        style: AppTextTheme.labelSmall
                            .colored(AppColors.warning)
                            .copyWith(fontSize: 11),
                      ),
                    ),
                ],
              ),
              if (widget.assignmentTitle != null)
                Text(
                  widget.assignmentTitle!,
                  style: AppTextTheme.appBarSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // ── Filter chips ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                for (int i = 0; i < _filters.length; i++) ...[
                  AppChip(
                    label: _filters[i],
                    selected: _filterIndex == i,
                    onTap: () => setState(() => _filterIndex = i),
                  ),
                  if (i < _filters.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ── Grading indicator ────────────────────────────────
        if (isGrading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: LinearProgressIndicator(
                backgroundColor: context.borderLight,
                color: AppColors.primary,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

        // ── List ─────────────────────────────────────────────
        filtered.isEmpty
            ? SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No Submissions',
                  subtitle: 'Student submissions will appear here.',
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SubmissionCard(
                      submission: filtered[i],
                      onGrade: (s) => _openGradeSheet(context, s),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
      ],
    );
  }

  void _openGradeSheet(BuildContext context, SubmissionModel submission) {
    final cubit = context.read<InstructorSubmissionsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GradeSheet(
        submission: submission,
        initialGrade: double.tryParse(submission.grade ?? '') ?? 75,
        onSubmit: (grade, feedback) {
          cubit.gradeSubmission(
            assignmentId: submission.assignmentId,
            studentId: submission.studentId,
            grade: grade,
            feedback: feedback,
          );
        },
      ),
    );
  }
}

// ─── Submission card ─────────────────────────────────────────

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.onGrade,
  });

  final SubmissionModel submission;
  final void Function(SubmissionModel) onGrade;

  Color _gradeColor(String grade) {
    final v = double.tryParse(grade);
    if (v != null) {
      if (v >= 90) return AppColors.success;
      if (v >= 75) return AppColors.primary;
      if (v >= 60) return AppColors.warning;
      return AppColors.error;
    }
    if (grade.startsWith('A')) return AppColors.success;
    if (grade.startsWith('B')) return AppColors.primary;
    if (grade.startsWith('C')) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onGrade(submission),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(name: submission.studentName, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.studentName,
                    style: AppTextTheme.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    submission.studentEmail,
                    style: AppTextTheme.bodySmall.colored(context.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    submission.assignmentTitle,
                    style: AppTextTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          submission.courseTitle,
                          style: AppTextTheme.labelSmall
                              .colored(AppColors.primary)
                              .copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.timeAgo(submission.submittedAt),
                        style: AppTextTheme.labelSmall
                            .colored(context.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (submission.isGraded && submission.grade != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _gradeColor(submission.grade!).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        submission.grade!,
                        style: AppTextTheme.labelLarge
                            .colored(_gradeColor(submission.grade!)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Re-grade',
                    style: AppTextTheme.labelSmall.colored(context.textTertiary),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () => onGrade(submission),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  'Grade',
                  style: AppTextTheme.labelMedium.colored(AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Grade bottom sheet ──────────────────────────────────────

class _GradeSheet extends StatefulWidget {
  const _GradeSheet({
    required this.submission,
    required this.onSubmit,
    this.initialGrade = 75,
  });

  final SubmissionModel submission;
  final void Function(double grade, String? feedback) onSubmit;
  final double initialGrade;

  @override
  State<_GradeSheet> createState() => _GradeSheetState();
}

class _GradeSheetState extends State<_GradeSheet> {
  late double _grade = widget.initialGrade;
  final _feedbackCtrl = TextEditingController();

  Color get _gradeColor {
    if (_grade >= 90) return AppColors.success;
    if (_grade >= 75) return AppColors.primary;
    if (_grade >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String get _gradeLabel {
    if (_grade >= 90) return 'Excellent';
    if (_grade >= 75) return 'Good';
    if (_grade >= 60) return 'Pass';
    return 'Fail';
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Text('Grade Submission', style: AppTextTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                '${widget.submission.studentName} · ${widget.submission.assignmentTitle}',
                style: AppTextTheme.bodySmall.colored(context.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 24),

              // Grade display
              Center(
                child: Column(
                  children: [
                    Text(
                      _grade.toStringAsFixed(0),
                      style: AppTextTheme.displaySmall.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _gradeColor,
                      ),
                    ),
                    Text(
                      _gradeLabel,
                      style: AppTextTheme.labelMedium.colored(_gradeColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _gradeColor,
                  thumbColor: _gradeColor,
                  inactiveTrackColor: context.borderLight,
                  overlayColor: _gradeColor.withValues(alpha: 0.12),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _grade,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (v) => setState(() => _grade = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0', style: AppTextTheme.labelSmall.colored(context.textTertiary)),
                  Text('100', style: AppTextTheme.labelSmall.colored(context.textTertiary)),
                ],
              ),

              const SizedBox(height: 20),

              Text('Feedback (optional)', style: AppTextTheme.inputLabel),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border),
                ),
                child: TextField(
                  controller: _feedbackCtrl,
                  maxLines: 3,
                  style: AppTextTheme.bodyMedium,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    hintText: 'Add feedback for the student...',
                    hintStyle: AppTextTheme.bodyMedium
                        .colored(context.textTertiary),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onSubmit(
                      _grade,
                      _feedbackCtrl.text.trim().isEmpty
                          ? null
                          : _feedbackCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Submit Grade',
                    style: AppTextTheme.buttonMedium
                        .colored(AppColors.textOnPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
