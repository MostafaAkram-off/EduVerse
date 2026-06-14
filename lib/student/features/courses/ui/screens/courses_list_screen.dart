import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import '../../data/models/course_model.dart';
import '../cubit/courses_cubit.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatelessWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CoursesCubit>()..loadCourses(),
      child: const _CoursesBody(),
    );
  }
}

class _CoursesBody extends StatelessWidget {
  const _CoursesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            CoursesLoading() => const _CoursesShimmer(),
            CoursesLoaded()  => _CoursesContent(state: state),
            CoursesError()   => _CoursesErrorView(
              message: (state).message,
              onRetry: () => context.read<CoursesCubit>().loadCourses(),
            ),
            _                => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LOADED CONTENT
// ─────────────────────────────────────────────
class _CoursesContent extends StatefulWidget {
  final CoursesLoaded state;
  const _CoursesContent({required this.state});

  @override
  State<_CoursesContent> createState() => _CoursesContentState();
}

class _CoursesContentState extends State<_CoursesContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<CoursesCubit>();
    final currentLevel = widget.state.selectedLevel;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Courses',
                  style: AppTextTheme.displaySmall.copyWith(color: ctx.textPrimary),
                ),
                if (currentLevel != 'All')
                  TextButton(
                    onPressed: () {
                      cubit.filterByLevel('All');
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Reset',
                      style: AppTextTheme.bodySemibold.copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Level',
              style: AppTextTheme.bodySmall.copyWith(color: ctx.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((level) {
                final isSelected = currentLevel == level;
                return GestureDetector(
                  onTap: () {
                    cubit.filterByLevel(level);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : ctx.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : ctx.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      level,
                      style: AppTextTheme.bodySemibold.copyWith(
                        color: isSelected ? Colors.white : ctx.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoursesCubit>();
    final state = widget.state;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore Courses', style: AppTextTheme.screenTitle),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: context.bg,
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
                          controller: _searchController,
                          onChanged: cubit.search,
                          style: AppTextTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search courses...',
                            hintStyle: AppTextTheme.inputHint,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showFilterSheet(context),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: state.selectedLevel != 'All'
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: state.selectedLevel != 'All'
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Category filter chips
                SizedBox(
                  height: MediaQuery.textScalerOf(context).scale(34).clamp(34.0, 52.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      final isActive = cat == state.selectedCategory;
                      return Padding(
                        padding: EdgeInsets.only(
                            right: index < state.categories.length - 1
                                ? 8
                                : 0),
                        child: GestureDetector(
                          onTap: () => cubit.filterByCategory(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : context.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : context.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: AppTextTheme.labelMedium.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : context.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Results count ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Text(
              '${state.filteredCourses.length} courses found',
              style: AppTextTheme.bodySmall,
            ),
          ),

          // ── Course list ───────────────────
          Expanded(
            child: state.filteredCourses.isEmpty
                ? _EmptySearch(
              onClear: () {
                _searchController.clear();
                cubit.search('');
                cubit.filterByCategory('All');
                cubit.filterByLevel('All');
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: state.filteredCourses.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CourseCard(
                  course: state.filteredCourses[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CourseDetailScreen(
                          course: state.filteredCourses[index],
                        ),
                      ),
                    );
                  },
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
// COURSE CARD
// ─────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        course.color.withValues(alpha: 0.8),
                        course.color,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: const Center(
                    child:
                    Icon(Icons.menu_book_rounded, size: 44, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _LevelBadge(level: course.level),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: AppTextTheme.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('by ${course.instructor}',
                      style: AppTextTheme.cardSubtitle),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Rating
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text('${course.rating}',
                          style: AppTextTheme.bodyBold
                              .copyWith(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text('(${course.reviewsCount})',
                          style: AppTextTheme.timestamp),
                      const SizedBox(width: 12),
                      // Duration
                      Icon(Icons.access_time,
                          size: 13, color: context.textTertiary),
                      const SizedBox(width: 3),
                      Text(course.duration,
                          style: AppTextTheme.bodySmall),
                      const Spacer(),
                      // Price
                      Text('\$${course.price.toInt()}',
                          style: AppTextTheme.priceSmall),
                    ],
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

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level,
        style: AppTextTheme.badgeSm.copyWith(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY SEARCH STATE
// ─────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptySearch({required this.onClear});

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
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No Results Found',
                style: AppTextTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or clear filters.',
              style: AppTextTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────
class _CoursesShimmer extends StatelessWidget {
  const _CoursesShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: context.surface,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _Shimmer(width: 200, height: 22),
              const SizedBox(height: 16),
              _Shimmer(width: double.infinity, height: 46, radius: 12),
              const SizedBox(height: 14),
              Row(children: List.generate(
                4,
                    (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Shimmer(width: 72, height: 34, radius: 999),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _Shimmer(
                    width: double.infinity, height: 200, radius: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Shimmer({
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.borderLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────
class _CoursesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CoursesErrorView(
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}