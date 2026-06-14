import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/enrollment/ui/screens/enroll_confirm_screen.dart';
import '../../data/models/course_model.dart';

class _ApiSession {
  final String id;
  final String title;
  final double duration;
  final int sessionNumber;

  const _ApiSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.sessionNumber,
  });

  factory _ApiSession.fromJson(Map<String, dynamic> json) => _ApiSession(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        duration: (json['duration'] as num?)?.toDouble() ?? 0,
        sessionNumber: json['sessionNumber'] as int? ?? 0,
      );
}

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
      body: Column(
        children: [
          // ── Hero ────────────────────────────
          _CourseHero(course: course),

          // ── Metrics bar ─────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
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
      height: (MediaQuery.of(context).size.height * 0.28).clamp(200.0, 260.0),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(m.icon, size: 14, color: m.iconColor),
                          const SizedBox(width: 3),
                          Text(m.value,
                              style: AppTextTheme.statValue
                                  .copyWith(fontSize: 15)),
                        ],
                      ),
                    ),
                    Text(m.sub,
                        style: AppTextTheme.timestamp
                            .copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                    width: 1, height: 32, color: context.borderLight),
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
                .copyWith(color: context.textSecondary, height: 1.7)),
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
class _CurriculumTab extends StatefulWidget {
  final CourseModel course;
  const _CurriculumTab({required this.course});

  @override
  State<_CurriculumTab> createState() => _CurriculumTabState();
}

class _CurriculumTabState extends State<_CurriculumTab> {
  List<_ApiSession>? _sessions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.getAllSessions(widget.course.id),
      );
      final list = response.data ?? [];
      final sessions = list
          .map((e) => _ApiSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
      if (mounted) setState(() { _sessions = sessions; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load sessions'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: context.textTertiary),
            const SizedBox(height: 12),
            Text(_error!, style: AppTextTheme.bodySmall),
            const SizedBox(height: 12),
            TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
                child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_sessions!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined, size: 48, color: context.textTertiary),
              const SizedBox(height: 12),
              const Text('No sessions yet', style: AppTextTheme.bodySmall),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions!.length,
      itemBuilder: (context, index) {
        final s = _sessions![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
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
                    if (s.duration > 0) ...[
                      const SizedBox(height: 2),
                      Text('${s.duration.toStringAsFixed(0)} min',
                          style: AppTextTheme.timestamp),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.play_circle_outline_rounded,
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
    final name = course.instructor.isNotEmpty ? course.instructor : course.title;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [course.color.withValues(alpha: 0.7), course.color],
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('Course Instructor', style: AppTextTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SmallBadge(
                          text: '${course.rating} ★',
                          bg: AppColors.warning.withValues(alpha: 0.12),
                          fg: AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Instructor information is not available yet.',
          style: AppTextTheme.bodyMedium
              .copyWith(color: context.textSecondary, height: 1.7),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Text('\$${course.price.toInt()}',
              style: AppTextTheme.price),
          const SizedBox(width: 16),
          Expanded(
            child: course.isEnrolled
                ? ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Continue Learning',
                      style: AppTextTheme.buttonMedium,
                    ),
                  )
                : _GradientEnrollButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => EnrollConfirmScreen(course: course),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GradientEnrollButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientEnrollButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradient1Start,
                AppColors.gradient1End,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Enroll Now',
                style: AppTextTheme.buttonMedium,
              ),
            ),
          ),
        ),
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