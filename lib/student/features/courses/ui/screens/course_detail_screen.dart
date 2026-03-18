import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import '../../data/models/course_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
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

  CourseModel get course => widget.course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Hero ────────────────────────────
          _CourseHero(course: course),

          // ── Metrics bar ─────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                _MetricsBar(course: course),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Curriculum'),
                    Tab(text: 'Instructor'),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab content ──────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(course: course),
                _CurriculumTab(course: course),
                _InstructorTab(course: course),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom action bar ────────────────────
      bottomNavigationBar: _BottomAction(course: course),
    );
  }
}

// ─────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────
class _CourseHero extends StatelessWidget {
  final CourseModel course;
  const _CourseHero({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [course.color.withValues(alpha: 0.8), course.color],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
            // Course info
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(text: course.category),
                  const SizedBox(height: 8),
                  Text(course.title,
                      style: AppTextTheme.certTitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('by ${course.instructor}',
                      style: AppTextTheme.certLabel.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 14),
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
// METRICS BAR
// ─────────────────────────────────────────────
class _MetricsBar extends StatelessWidget {
  final CourseModel course;
  const _MetricsBar({required this.course});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(
        value: '${course.rating}',
        sub: '${course.reviewsCount} reviews',
        icon: Icons.star_rounded,
        iconColor: AppColors.warning,
      ),
      _Metric(
        value: '${course.studentsCount}',
        sub: 'students',
        icon: Icons.people_alt_rounded,
        iconColor: AppColors.primary,
      ),
      _Metric(
        value: course.duration,
        sub: 'duration',
        icon: Icons.access_time_rounded,
        iconColor: AppColors.success,
      ),
      _Metric(
        value: course.level,
        sub: 'level',
        icon: Icons.bar_chart_rounded,
        iconColor: AppColors.secondary,
      ),
    ];

    return Row(
      children: metrics.map((m) {
        final isLast = m == metrics.last;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m.icon, size: 14, color: m.iconColor),
                        const SizedBox(width: 3),
                        Text(m.value,
                            style: AppTextTheme.statValue
                                .copyWith(fontSize: 15)),
                      ],
                    ),
                    Text(m.sub,
                        style: AppTextTheme.timestamp
                            .copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                    width: 1, height: 32, color: AppColors.borderLight),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Metric {
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;
  const _Metric(
      {required this.value,
        required this.sub,
        required this.icon,
        required this.iconColor});
}

// ─────────────────────────────────────────────
// ABOUT TAB
// ─────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final CourseModel course;
  const _AboutTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(course.description,
            style: AppTextTheme.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.7)),
        const SizedBox(height: 24),
        Text("What you'll learn",
            style: AppTextTheme.displaySmall.copyWith(fontSize: 15)),
        const SizedBox(height: 12),
        ...course.whatYouLearn.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      size: 12, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: AppTextTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CURRICULUM TAB
// ─────────────────────────────────────────────
class _CurriculumTab extends StatelessWidget {
  final CourseModel course;
  const _CurriculumTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: course.modules.length,
      itemBuilder: (context, index) {
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
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
                    Text(course.modules[index],
                        style: AppTextTheme.bodySemibold),
                    const SizedBox(height: 2),
                    Text('4–6 sessions',
                        style: AppTextTheme.timestamp),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline_rounded,
                  size: 22, color: AppColors.primary),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// INSTRUCTOR TAB
// ─────────────────────────────────────────────
class _InstructorTab extends StatelessWidget {
  final CourseModel course;
  const _InstructorTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    course.color.withValues(alpha: 0.7),
                    course.color,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  course.instructor.substring(0, 1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.instructor,
                      style: AppTextTheme.displaySmall
                          .copyWith(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('Senior Designer · Google',
                      style: AppTextTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SmallBadge(
                          text: '4.9 ★',
                          bg: AppColors.warningLight,
                          fg: AppColors.warning),
                      _SmallBadge(
                          text: '12 courses',
                          bg: AppColors.borderLight,
                          fg: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '10+ years of experience in product design at top tech companies. '
              'Passionate about teaching and mentoring the next generation of designers.',
          style: AppTextTheme.bodyMedium
              .copyWith(color: AppColors.textSecondary, height: 1.7),
        ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _SmallBadge(
      {required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
          text,
          style:
          AppTextTheme.badgeSm.copyWith(color: fg, fontSize: 11)),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM ACTION BAR
// ─────────────────────────────────────────────
class _BottomAction extends StatelessWidget {
  final CourseModel course;
  const _BottomAction({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Text('\$${course.price.toInt()}',
              style: AppTextTheme.price),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: course.isEnrolled
                    ? AppColors.success
                    : AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                course.isEnrolled ? 'Continue Learning' : 'Enroll Now',
                style: AppTextTheme.buttonMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLES
// ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: AppTextTheme.badgeSm
              .copyWith(color: Colors.white, fontSize: 11)),
    );
  }
}