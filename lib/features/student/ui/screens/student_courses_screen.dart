import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/app_progress_bar.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/student/data/models/enrolled_course.dart';
import 'package:edu_verse/features/student/ui/cubit/student_cubit.dart';
import 'package:edu_verse/features/student/ui/cubit/student_state.dart';
import 'package:edu_verse/features/student/ui/screens/student_course_detail_screen.dart';

class StudentCoursesScreen extends StatelessWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            _buildHeader(state),
            if (state is StudentLoading || state is StudentInitial)
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const ShimmerList(itemCount: 5, itemHeight: 100),
                  ]),
                ),
              )
            else if (state is StudentLoaded)
              _buildCourseList(state.courses)
            else if (state is StudentError)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    state.message,
                    style: AppTextTheme.bodyMedium.colored(AppColors.error),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  SliverAppBar _buildHeader(StudentState state) {
    final count = state is StudentLoaded ? state.courses.length : 0;
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'My Courses',
                    style: AppTextTheme.displayMedium.colored(Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count courses enrolled',
                    style: AppTextTheme.bodySmall
                        .colored(Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildCourseList(List<EnrolledCourse> courses) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      sliver: SliverList.separated(
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _CourseListCard(course: courses[index]),
      ),
    );
  }
}

class _CourseListCard extends StatelessWidget {
  final EnrolledCourse course;
  const _CourseListCard({required this.course});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentCourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = course.progressPercent >= 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Gradient avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: course.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  course.title[0].toUpperCase(),
                  style: AppTextTheme.displaySmall.colored(Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppTextTheme.cardTitle.copyWith(color: context.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      course.instructorName,
                      style: AppTextTheme.cardSubtitle
                          .colored(context.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.category,
                        style: AppTextTheme.labelSmall
                            .colored(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing icon
              if (isCompleted)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 24)
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary, size: 16),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar + label
          AppProgressBar(
            value: course.progressPercent,
            color: course.gradientColors.first,
            height: 6,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${course.completedSessions}/${course.totalSessions} sessions',
                style:
                    AppTextTheme.labelSmall.colored(context.textSecondary),
              ),
              Text(
                '${(course.progressPercent * 100).toInt()}% complete',
                style: AppTextTheme.labelSmall
                    .colored(course.gradientColors.first),
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
