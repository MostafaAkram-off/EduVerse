import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_avatar.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/app_chip.dart';
import 'package:edu_verse/core/widgets/app_progress_bar.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/student_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key});

  @override
  State<InstructorStudentsScreen> createState() =>
      _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState
    extends State<InstructorStudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCourse = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorCubit, InstructorState>(
      builder: (context, state) => Scaffold(
        backgroundColor: context.bg,
        body: switch (state) {
          InstructorLoading() || InstructorInitial() => _Skeleton(),
          InstructorLoaded(:final students) =>
            _Body(
              allStudents: students,
              query: _query,
              selectedCourse: _selectedCourse,
              searchCtrl: _searchCtrl,
              onSearch: (v) => setState(() => _query = v),
              onFilter: (c) => setState(() => _selectedCourse = c),
            ),
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
  const _Body({
    required this.allStudents,
    required this.query,
    required this.selectedCourse,
    required this.searchCtrl,
    required this.onSearch,
    required this.onFilter,
  });

  final List<StudentModel> allStudents;
  final String query;
  final String selectedCourse;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFilter;

  List<String> get _courses {
    final names = allStudents.map((s) => s.course).toSet().toList()..sort();
    return ['All', ...names];
  }

  List<StudentModel> get _filtered {
    return allStudents.where((s) {
      final matchCourse =
          selectedCourse == 'All' || s.course == selectedCourse;
      final matchQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.email.toLowerCase().contains(query.toLowerCase());
      return matchCourse && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return CustomScrollView(
      slivers: [
        // ── App bar ───────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Students', style: AppTextTheme.screenTitle),
              Text(
                '${allStudents.length} enrolled',
                style: AppTextTheme.appBarSubtitle,
              ),
            ],
          ),
        ),

        // ── Search bar ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search,
                      size: 18, color: context.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: onSearch,
                      style: AppTextTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email…',
                        hintStyle: AppTextTheme.inputHint,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 16, color: context.textTertiary),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearch('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Course filter chips ───────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _courses[i];
                return AppChip(
                  label: c,
                  selected: selectedCourse == c,
                  onTap: () => onFilter(c),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ── Student list ──────────────────────────────────
        filtered.isEmpty
            ? SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No Students Found',
                  subtitle: 'Try adjusting your search or filter.',
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StudentCard(student: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
      ],
    );
  }
}

// ─── Student card ─────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final StudentModel student;

  BadgeType get _gradeType {
    final g = student.grade;
    final v = double.tryParse(g);
    if (v != null) {
      if (v >= 90) return BadgeType.active;
      if (v >= 75) return BadgeType.upcoming;
      return BadgeType.draft;
    }
    if (g.startsWith('A')) return BadgeType.active;
    if (g.startsWith('B')) return BadgeType.upcoming;
    return BadgeType.draft;
  }

  Color get _attendanceColor {
    if (student.attendance >= 85) return AppColors.success;
    if (student.attendance >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStudentDetail(context),
      child: Container(
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
          // Avatar
          AppAvatar(name: student.name, radius: 24),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + grade badge (hidden when no grade)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: AppTextTheme.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (student.grade.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      AppBadge(label: student.grade, type: _gradeType),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // Email
                Text(
                  student.email,
                  style: AppTextTheme.timestamp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Course chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    student.course,
                    style:
                        AppTextTheme.labelSmall.colored(AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),

                // Progress
                Row(
                  children: [
                    Expanded(
                      child: AppProgressBar(
                        value: student.progressPercent / 100,
                        height: 5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${student.progressPercent}%',
                      style: AppTextTheme.labelSmall
                          .colored(AppColors.primary),
                    ),
                  ],
                ),
                if (student.attendance > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.event_available_rounded,
                          size: 13, color: _attendanceColor),
                      const SizedBox(width: 4),
                      Text(
                        'Attendance: ${student.attendance}%',
                        style: AppTextTheme.labelSmall
                            .colored(_attendanceColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ), // Container
    ); // GestureDetector
  }

  void _showStudentDetail(BuildContext context) {
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
              const SizedBox(height: 20),
              Row(
                children: [
                  AppAvatar(name: student.name, radius: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name, style: AppTextTheme.displaySmall),
                        const SizedBox(height: 2),
                        Text(student.email,
                            style: AppTextTheme.bodySmall
                                .colored(context.textSecondary)),
                      ],
                    ),
                  ),
                  if (student.grade.isNotEmpty)
                    AppBadge(label: student.grade, type: _gradeType),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(student.course,
                    style:
                        AppTextTheme.labelMedium.colored(AppColors.primary)),
              ),
              const SizedBox(height: 20),
              _StudentStatRow(
                label: 'Progress',
                value: '${student.progressPercent}%',
                progress: student.progressPercent / 100,
                color: AppColors.primary,
              ),
              if (student.attendance > 0) ...[
                const SizedBox(height: 12),
                _StudentStatRow(
                  label: 'Attendance',
                  value: '${student.attendance}%',
                  progress: student.attendance / 100,
                  color: _attendanceColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentStatRow extends StatelessWidget {
  const _StudentStatRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });
  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    AppTextTheme.bodySmall.colored(context.textSecondary)),
            Text(value,
                style: AppTextTheme.bodySemibold.colored(color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
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
          title: Text('Students', style: AppTextTheme.screenTitle),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: ShimmerList(itemCount: 5, itemHeight: 120),
          ),
        ),
      ],
    );
  }
}
