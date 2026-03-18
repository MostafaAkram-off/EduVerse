import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import '../../data/models/enrolled_course_model.dart';
import '../cubit/learning_cubit.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LearningCubit()..loadLearning(),
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
          backgroundColor: AppColors.background,
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
            color: AppColors.surface,
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
                      : AppColors.textSecondary,
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
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextTheme.badgeSm.copyWith(
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
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
                                  backgroundColor:
                                  AppColors.borderLight,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: AppColors.background,
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
                _SessionsTab(enrolled: widget.enrolled),
                _AssignmentsTab(enrolled: widget.enrolled),
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
  final EnrolledCourseModel enrolled;
  const _SessionsTab({required this.enrolled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrolled.sessions.length,
      itemBuilder: (context, index) {
        final session = enrolled.sessions[index];
        final isLive = session.status == 'live';
        final isDone = session.status == 'completed';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.successLight
                      : isLive
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : isLive
                      ? Icons.play_circle_fill_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 22,
                  color: isDone
                      ? AppColors.success
                      : isLive
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: AppTextTheme.bodySemibold),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12,
                            color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text('${session.date} · ${session.time}',
                            style: AppTextTheme.timestamp),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _StatusBadge(status: session.status),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// ASSIGNMENTS TAB
// ─────────────────────────────────────────────
class _AssignmentsTab extends StatelessWidget {
  final EnrolledCourseModel enrolled;
  const _AssignmentsTab({required this.enrolled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrolled.assignments.length,
      itemBuilder: (context, index) {
        final a = enrolled.assignments[index];
        final isGraded = a.status == 'graded';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: AppTextTheme.cardTitle),
                    const SizedBox(height: 3),
                    Text('Due: ${a.dueDate} · ${a.maxPoints} pts',
                        style: AppTextTheme.timestamp),
                    const SizedBox(height: 8),
                    _StatusBadge(status: a.status),
                  ],
                ),
              ),
              if (isGraded && a.grade != null) ...[
                Column(
                  children: [
                    Text(
                      '${a.grade}',
                      style: AppTextTheme.statValue.copyWith(
                        color: a.grade! >= 90
                            ? AppColors.success
                            : a.grade! >= 70
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    ),
                    Text('/ ${a.maxPoints}',
                        style: AppTextTheme.timestamp),
                  ],
                ),
              ],
            ],
          ),
        );
      },
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: course.progressPercent / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.borderLight,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
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
                    value: item.value / item.total,
                    minHeight: 7,
                    backgroundColor: AppColors.borderLight,
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

  Color get _bg => switch (status) {
    'graded' || 'completed' => AppColors.successLight,
    'submitted' || 'live'   => AppColors.primaryLight,
    _                       => AppColors.warningLight,
  };

  Color get _fg => switch (status) {
    'graded' || 'completed' => AppColors.success,
    'submitted' || 'live'   => AppColors.primary,
    _                       => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
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
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
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
            color: AppColors.surface,
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
        color: AppColors.borderLight,
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
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
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