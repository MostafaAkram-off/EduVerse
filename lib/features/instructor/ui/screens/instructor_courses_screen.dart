import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/app_chip.dart';
import 'package:edu_verse/core/widgets/app_progress_bar.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/error_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/course_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState
    extends State<InstructorCoursesScreen> {
  int _filterIndex = 0; // 0=All, 1=Active, 2=Draft

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorCubit, InstructorState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.bg,
          body: switch (state) {
            InstructorLoading() || InstructorInitial() =>
              _buildSkeleton(context),
            InstructorLoaded() =>
              _buildBody(context, state),
            InstructorError(:final message) => ErrorState(
                message: message,
                onRetry: () =>
                    context.read<InstructorCubit>().loadData(),
              ),
            _ => const SizedBox(),
          },
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course creation coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Add Course',
                style: AppTextTheme.buttonSmall
                    .colored(AppColors.textOnPrimary)),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, InstructorLoaded state) {
    final all = state.courses;
    final filtered = switch (_filterIndex) {
      1 => all.where((c) => c.status == CourseStatus.active).toList(),
      2 => all.where((c) => c.status == CourseStatus.draft).toList(),
      _ => all,
    };

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
              Text('My Courses', style: AppTextTheme.screenTitle),
              Text('${all.length} total',
                  style: AppTextTheme.appBarSubtitle),
            ],
          ),
        ),

        // ── Filter chips ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Courses grid ──────────────────────────────────
        filtered.isEmpty
            ? SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.book_outlined,
                  title: 'No courses here',
                  subtitle: 'Adjust the filter or create a new course.',
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CourseCard(course: filtered[i]),
                    childCount: filtered.length,
                  ),
                ),
              ),
      ],
    );
  }

  static const _filters = ['All', 'Active', 'Draft'];

  Widget _buildSkeleton(BuildContext context) => CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bg,
            elevation: 0,
            title: Text('My Courses', style: AppTextTheme.screenTitle),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: ShimmerGrid(crossAxisCount: 2, itemCount: 6),
            ),
          ),
        ],
      );
}

// ─── Course card ─────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final isActive = course.status == CourseStatus.active;

    return GestureDetector(
      onTap: () => _showCourseDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover gradient ─────────────────────────
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: course.coverGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: GridView.count(
                        crossAxisCount: 6,
                        children: List.generate(
                          24,
                          (_) => const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AppBadge(
                      label: course.statusLabel,
                      type: isActive
                          ? BadgeType.active
                          : BadgeType.draft,
                    ),
                  ),
                  // Category icon
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _categoryIcon(course.category),
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.category,
                      style:
                          AppTextTheme.labelSmall.colored(AppColors.primary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      course.title,
                      style: AppTextTheme.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Stats row
                    Row(
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 12,
                            color: context.textTertiary),
                        const SizedBox(width: 3),
                        Text('${course.studentsCount}',
                            style: AppTextTheme.labelSmall),
                        const SizedBox(width: 8),
                        Icon(Icons.layers_outlined,
                            size: 12,
                            color: context.textTertiary),
                        const SizedBox(width: 3),
                        Text('${course.sessionsCount}',
                            style: AppTextTheme.labelSmall),
                      ],
                    ),
                    if (isActive && course.completionRate > 0) ...[
                      const SizedBox(height: 8),
                      AppProgressBar(
                        value: course.completionRate,
                        showPercent: true,
                        height: 4,
                        color: course.coverGradient.first,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) => switch (cat.toLowerCase()) {
        'mobile dev'      => Icons.smartphone_rounded,
        'web dev'         => Icons.web_rounded,
        'design'          => Icons.palette_rounded,
        'data'            => Icons.bar_chart_rounded,
        'infrastructure'  => Icons.dns_rounded,
        _                 => Icons.school_rounded,
      };

  void _showCourseDetail(BuildContext context) {
    final isActive = course.status == CourseStatus.active;
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
              // Header gradient strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: course.coverGradient),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.category,
                            style: AppTextTheme.labelSmall
                                .colored(AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(course.title,
                            style: AppTextTheme.displaySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppBadge(
                    label: course.statusLabel,
                    type: isActive ? BadgeType.active : BadgeType.draft,
                  ),
                ],
              ),
              if (course.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(course.description,
                    style: AppTextTheme.bodyMedium
                        .colored(context.textSecondary)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _CourseStat(
                    icon: Icons.people_outline_rounded,
                    value: '${course.studentsCount}',
                    label: 'Students',
                  ),
                  const SizedBox(width: 24),
                  _CourseStat(
                    icon: Icons.layers_outlined,
                    value: '${course.sessionsCount}',
                    label: 'Sessions',
                  ),
                  if (isActive && course.completionRate > 0) ...[
                    const SizedBox(width: 24),
                    _CourseStat(
                      icon: Icons.verified_rounded,
                      value:
                          '${(course.completionRate * 100).toStringAsFixed(0)}%',
                      label: 'Completion',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseStat extends StatelessWidget {
  const _CourseStat(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textTertiary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextTheme.bodySemibold),
            Text(label,
                style: AppTextTheme.labelSmall
                    .colored(context.textTertiary)),
          ],
        ),
      ],
    );
  }
}
