import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
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
        backgroundColor: AppColors.background,
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
          backgroundColor: AppColors.background,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search,
                      size: 18, color: AppColors.textTertiary),
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
                      icon: const Icon(Icons.close,
                          size: 16, color: AppColors.textTertiary),
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
    return Container(
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
                // Name + grade badge
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
                    const SizedBox(width: 8),
                    AppBadge(
                      label: student.grade,
                      type: _gradeType,
                    ),
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
                    color: AppColors.primaryLight,
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
                const SizedBox(height: 6),

                // Attendance
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
            ),
          ),
        ],
      ),
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
          backgroundColor: AppColors.background,
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
