import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/enrollment/ui/screens/enroll_confirm_screen.dart';
import '../../data/models/course_model.dart';

class _ApiSession {
  final String id;
  final String title;
  final double duration;   // in hours (e.g. 0.2885 → ~17 min)
  final int sessionNumber;
  final String description;
  final String fileUrl;
  final String? videoUrl;
  final String? externalLink;
  final DateTime? date;

  const _ApiSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.sessionNumber,
    required this.description,
    required this.fileUrl,
    this.videoUrl,
    this.externalLink,
    this.date,
  });

  String get durationLabel {
    final totalMin = (duration * 60).round();
    if (totalMin <= 0) return '';
    if (totalMin < 60) return '${totalMin}m';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  factory _ApiSession.fromJson(Map<String, dynamic> json) => _ApiSession(
        id:            json['id'] as String? ?? '',
        title:         json['title'] as String? ?? '',
        duration:      (json['duration'] as num?)?.toDouble() ?? 0,
        sessionNumber: json['sessionNumber'] as int? ?? 0,
        description:   json['description'] as String? ?? '',
        fileUrl:       json['fileUrl'] as String? ?? '',
        videoUrl:      json['videoUrl'] as String?,
        externalLink:  json['externalLink'] as String?,
        date:          DateTime.tryParse(json['date'] as String? ?? ''),
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
    _tabController = TabController(length: 4, vsync: this);
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
                    Tab(text: 'Recommended'),
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
                _RecommendedTab(course: course),
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
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = GetIt.instance<Dio>();
      final response = await dio.get<dynamic>(
        ApiEndpoints.getAllSessions(widget.course.id),
      );
      final raw = response.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['sessions'] ?? []) as List)
              : <dynamic>[];
      final sessions = list
          .map((e) => _ApiSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
      if (mounted) setState(() { _sessions = sessions; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load sessions'; _loading = false; });
    }
  }

  void _toggle(String id) =>
      setState(() => _expandedId = _expandedId == id ? null : id);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: context.textTertiary),
            const SizedBox(height: 12),
            Text(_error!, style: AppTextTheme.bodySmall),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Text('Retry', style: AppTextTheme.labelMedium.colored(AppColors.primary)),
            ),
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
              Text('No sessions yet',
                  style: AppTextTheme.bodySmall.colored(context.textSecondary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _sessions!.length,
      itemBuilder: (_, i) => _SessionTile(
        session: _sessions![i],
        isExpanded: _expandedId == _sessions![i].id,
        onTap: () => _toggle(_sessions![i].id),
      ),
    );
  }
}

// ─── Session accordion tile ──────────────────
class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isExpanded,
    required this.onTap,
  });

  final _ApiSession session;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasContent = session.description.isNotEmpty ||
        (session.videoUrl != null && session.videoUrl!.isNotEmpty) ||
        (session.externalLink != null && session.externalLink!.isNotEmpty) ||
        session.fileUrl.isNotEmpty ||
        session.date != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.40)
              : context.borderLight,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: hasContent ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${session.sessionNumber}',
                          style: AppTextTheme.bodyBold.copyWith(
                            color: isExpanded ? Colors.white : AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.title,
                              style: AppTextTheme.bodySemibold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (session.durationLabel.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 11, color: context.textTertiary),
                                const SizedBox(width: 3),
                                Text(session.durationLabel,
                                    style: AppTextTheme.timestamp),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasContent)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 22, color: context.textTertiary),
                      ),
                  ],
                ),

                // ── Expandable content ──────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? _SessionDetail(session: session)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Session expanded detail ─────────────────
class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.session});
  final _ApiSession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Date
          if (session.date != null) ...[
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: _formatDate(session.date!),
            ),
            const SizedBox(height: 10),
          ],

          // Description
          if (session.description.isNotEmpty) ...[
            Text(session.description,
                style: AppTextTheme.bodySmall.copyWith(
                  color: context.textSecondary,
                  height: 1.6,
                )),
            const SizedBox(height: 14),
          ],

          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.videoUrl != null && session.videoUrl!.isNotEmpty)
                _ActionButton(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Watch Video',
                  color: AppColors.primary,
                  url: session.videoUrl!,
                ),
              if (session.externalLink != null && session.externalLink!.isNotEmpty)
                _ActionButton(
                  icon: Icons.open_in_new_rounded,
                  label: 'Open Link',
                  color: AppColors.secondary,
                  url: session.externalLink!,
                ),
              if (session.fileUrl.isNotEmpty)
                _ActionButton(
                  icon: Icons.attach_file_rounded,
                  label: 'View Material',
                  color: AppColors.success,
                  url: '${ApiEndpoints.baseUrl}/Cloud/Get/SessionMaterial/${session.fileUrl}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: context.textTertiary),
        const SizedBox(width: 6),
        Text(label,
            style: AppTextTheme.timestamp.copyWith(color: context.textSecondary)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launch(context, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextTheme.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl');
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          ),
        );
      }
    }
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

// ─────────────────────────────────────────────
// RECOMMENDED TAB
// ─────────────────────────────────────────────
class _RecommendedTab extends StatefulWidget {
  final CourseModel course;
  const _RecommendedTab({required this.course});

  @override
  State<_RecommendedTab> createState() => _RecommendedTabState();
}

class _RecommendedTabState extends State<_RecommendedTab> {
  List<CourseModel>? _courses;
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
      final res = await dio.get<dynamic>(
        ApiEndpoints.recommendationsSimilar(widget.course.id),
      );
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['recommendations'] ?? raw['courses'] ?? []) as List)
              : <dynamic>[];
      final courses = list
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _courses = courses; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load recommendations'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: context.textTertiary),
            const SizedBox(height: 12),
            Text(_error!, style: AppTextTheme.bodySmall.colored(context.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _load();
              },
              child: Text('Retry', style: AppTextTheme.labelMedium.colored(AppColors.primary)),
            ),
          ],
        ),
      );
    }
    if (_courses!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.school_outlined, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text('No Similar Courses', style: AppTextTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find similar courses at this time.',
                style: AppTextTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses!.length,
      itemBuilder: (_, i) {
        final c = _courses![i];
        return _RecommendedCard(
          course: c,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CourseDetailScreen(course: c),
            ),
          ),
        );
      },
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.course, required this.onTap});
  final CourseModel course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
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
          children: [
            // Thumbnail
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [course.color.withValues(alpha: 0.8), course.color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.menu_book_rounded, size: 30, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
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
                      style: AppTextTheme.cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text('${course.rating}',
                          style: AppTextTheme.bodySmall
                              .copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('\$${course.price.toInt()}',
                          style: AppTextTheme.labelMedium
                              .colored(AppColors.primary)),
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
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RateButton(courseId: course.id),
                    ],
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

// ─── Rate button ─────────────────────────────────────────────

class _RateButton extends StatefulWidget {
  const _RateButton({required this.courseId});
  final String courseId;

  @override
  State<_RateButton> createState() => _RateButtonState();
}

class _RateButtonState extends State<_RateButton> {
  bool _submitted = false;

  void _showRatingSheet() {
    int selected = 0;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24, right: 24, top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Rate this Course', style: AppTextTheme.displaySmall),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => set(() => selected = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        star <= selected ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 40,
                        color: star <= selected ? AppColors.warning : AppColors.textSecondary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selected == 0
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          try {
                            final dio = GetIt.instance<Dio>();
                            await dio.post<dynamic>(
                              ApiEndpoints.addRating,
                              data: {'courseId': widget.courseId, 'ratingValue': selected},
                            );
                          } catch (_) {}
                          if (mounted) setState(() => _submitted = true);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Submit Rating', style: AppTextTheme.buttonMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _submitted ? null : _showRatingSheet,
      style: OutlinedButton.styleFrom(
        foregroundColor: _submitted ? AppColors.success : AppColors.primary,
        side: BorderSide(
          color: _submitted ? AppColors.success : AppColors.primary,
        ),
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: EdgeInsets.zero,
      ),
      child: Icon(
        _submitted ? Icons.star_rounded : Icons.star_outline_rounded,
        size: 22,
        color: _submitted ? AppColors.success : AppColors.primary,
      ),
    );
  }
}

// ─── Enroll button ────────────────────────────────────────────

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