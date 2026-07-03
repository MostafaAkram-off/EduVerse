import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/utils/format_utils.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_theme.dart';
import '../../../../../core/theme/theme_ext.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';
import 'package:edu_verse/student/features/home/ui/cubit/home_cubit.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'package:edu_verse/student/features/courses/ui/screens/course_detail_screen.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning ☀️';
  if (h < 17) return 'Good Afternoon 🌤️';
  if (h < 21) return 'Good Evening 🌙';
  return 'Good Night 🌛';
}

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({
    super.key,
    this.onSwitchTab,
    this.onOpenNotifications,
  });

  /// Bottom tab index: 1 = Courses, 2 = My Learning.
  final ValueChanged<int>? onSwitchTab;
  final VoidCallback? onOpenNotifications;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<HomeCubit>()..loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _HomeBody(
        onSwitchTab: widget.onSwitchTab,
        onOpenNotifications: widget.onOpenNotifications,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    this.onSwitchTab,
    this.onOpenNotifications,
  });

  final ValueChanged<int>? onSwitchTab;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            HomeLoading() => const _HomeShimmer(),
            HomeLoaded() => _HomeContent(
              state: state,
              onSwitchTab: onSwitchTab,
              onOpenNotifications: onOpenNotifications,
            ),
            HomeError()  => _HomeErrorView(
              message: (state).message,
              onRetry: () => context.read<HomeCubit>().loadHome(),
            ),
            _            => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LOADED CONTENT
// ─────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  final ValueChanged<int>? onSwitchTab;
  final VoidCallback? onOpenNotifications;

  const _HomeContent({
    required this.state,
    this.onSwitchTab,
    this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting row
                  ListenableBuilder(
                    listenable: AppPreferences.instance,
                    builder: (context, _) {
                      final prefs = AppPreferences.instance;
                      final photoUrl = prefs.profilePictureFilename.isNotEmpty
                          ? '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(prefs.profilePictureFilename)}'
                          : null;
                      return Row(
                        children: [
                          _Avatar(
                            initials: prefs.initials(),
                            size: 44,
                            photoUrl: photoUrl,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_greeting(), style: AppTextTheme.greeting),
                                Text(
                                  prefs.userName.isNotEmpty ? prefs.userName : 'Student',
                                  style: AppTextTheme.greetingName,
                                ),
                              ],
                            ),
                          ),
                          _NotificationButton(
                            onTap: onOpenNotifications ?? () {},
                            hasUnread: state.unreadNotifications > 0,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Continue learning banner
                  if (state.enrolledCourses.isNotEmpty)
                    _ContinueLearningBanner(
                      course: state.enrolledCourses.first,
                      onResume: () => onSwitchTab?.call(2),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Stats ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _StatCard(
                    label: 'Courses',
                    value: '${state.enrolledCourses.length}',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Completed',
                    value: '${state.completedCourses}',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Hours',
                    value: '${state.totalHours}h',
                    icon: Icons.access_time_rounded,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
          ),

          // ── My Courses ────────────────────────
          SliverToBoxAdapter(
            child: state.enrolledCourses.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: _SectionHeader(
                      title: 'My Courses',
                      onSeeAll: () => onSwitchTab?.call(2),
                    ),
                  ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final course = state.enrolledCourses[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _InProgressCard(
                    course: course,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CourseDetailScreen(course: course),
                      ),
                    ),
                  ),
                );
              },
              childCount: state.enrolledCourses.take(3).length,
            ),
          ),

          // ── Recommended courses ──────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
              child: _SectionHeader(
                title: 'Recommended Courses',
                onSeeAll: () => onSwitchTab?.call(1),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: (90 + 130 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(220.0, 290.0),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: state.recommendedCourses.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _RecommendedCard(
                    course: state.recommendedCourses[index],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CourseDetailScreen(
                            course: state.recommendedCourses[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── Trending courses ──────────────────
          if (state.trendingCourses.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
                child: _SectionHeader(
                  title: 'Trending Now',
                  onSeeAll: () => onSwitchTab?.call(1),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: (90 + 130 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(220.0, 290.0),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.trendingCourses.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _RecommendedCard(
                      course: state.trendingCourses[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CourseDetailScreen(
                              course: state.trendingCourses[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTINUE LEARNING BANNER
// ─────────────────────────────────────────────
class _ContinueLearningBanner extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onResume;
  const _ContinueLearningBanner({
    required this.course,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradient1Start, AppColors.gradient1End],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Learning!',
                  style: AppTextTheme.displaySmall
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.title} — ${course.progressPercent}% complete',
                  style: AppTextTheme.bodySmall
                      .copyWith(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: course.progressPercent / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white30,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Resume button
                GestureDetector(
                  onTap: onResume,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Resume →',
                      style: AppTextTheme.buttonSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Course thumbnail or fallback emoji
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: course.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _BannerThumbFallback(),
                        errorWidget: (_, __, ___) =>
                            const _BannerThumbFallback(),
                      )
                    : const _BannerThumbFallback(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerThumbFallback extends StatelessWidget {
  const _BannerThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.15),
      child: const Center(
        child: Text('📚', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTextTheme.statValue),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextTheme.statLabel),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IN-PROGRESS COURSE CARD
// ─────────────────────────────────────────────
class _InProgressCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  const _InProgressCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderLight),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _CourseGradientPlaceholder(
                              color: course.color, iconSize: 22),
                          errorWidget: (_, __, ___) =>
                              _CourseGradientPlaceholder(
                                  color: course.color, iconSize: 22),
                        )
                      : _CourseGradientPlaceholder(
                          color: course.color, iconSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppTextTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.category.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(course.category, style: AppTextTheme.timestamp),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: course.progressPercent / 100,
                              minHeight: 4,
                              backgroundColor: context.borderLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  course.color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${course.progressPercent}%',
                          style: AppTextTheme.timestamp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  size: 18, color: context.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECOMMENDED COURSE CARD
// ─────────────────────────────────────────────
class _RecommendedCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  const _RecommendedCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 90,
                width: double.infinity,
                child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: course.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _CourseGradientPlaceholder(color: course.color, iconSize: 36),
                        errorWidget: (_, __, ___) => _CourseGradientPlaceholder(color: course.color, iconSize: 36),
                      )
                    : _CourseGradientPlaceholder(color: course.color, iconSize: 36),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: AppTextTheme.bodyLarge.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: AppTextTheme.timestamp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(builder: (context) {
                        final r = formatRating(course.rating,
                            reviewsCount: course.reviewsCount);
                        return r != null
                            ? Row(children: [
                                const Icon(Icons.star_rounded,
                                    size: 13, color: AppColors.warning),
                                const SizedBox(width: 2),
                                Text(r,
                                    style: AppTextTheme.bodyLarge
                                        .copyWith(fontSize: 12)),
                              ])
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('New',
                                    style: AppTextTheme.badgeSm.copyWith(
                                        color: AppColors.success,
                                        fontSize: 10)),
                              );
                      }),
                      Text(
                        formatPrice(course.price),
                        style: AppTextTheme.priceSmall.copyWith(fontSize: 14),
                      ),
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

class _CourseGradientPlaceholder extends StatelessWidget {
  final Color color;
  final double iconSize;
  const _CourseGradientPlaceholder({required this.color, this.iconSize = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.8), color],
        ),
      ),
      child: Center(
        child: Icon(Icons.menu_book_rounded, size: iconSize, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE SMALL WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('See all', style: AppTextTheme.link.copyWith(fontSize: 13)),
        ),
      ],
    );
  }
}


class _Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final String? photoUrl;
  const _Avatar({required this.initials, required this.size, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          httpHeaders: AuthSession.token != null
              ? {'Authorization': 'Bearer ${AuthSession.token}'}
              : const {},
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallback(),
          placeholder: (_, __) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.gradient1Start, AppColors.gradient1End],
        ),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasUnread;
  const _NotificationButton({required this.onTap, this.hasUnread = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.notifications_outlined,
                  size: 22, color: context.textPrimary),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.bg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHIMMER LOADING
// ─────────────────────────────────────────────
class _HomeShimmer extends StatefulWidget {
  const _HomeShimmer();

  @override
  State<_HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<_HomeShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _fade =
      Tween(begin: 0.45, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _Shimmer(width: 44, height: 44, radius: 22),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Shimmer(width: 80, height: 12),
                  const SizedBox(height: 6),
                  _Shimmer(width: 140, height: 16),
                ]),
              ]),
              const SizedBox(height: 20),
              _Shimmer(width: double.infinity, height: 120, radius: 20),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _Shimmer(height: 80, radius: 14)),
                const SizedBox(width: 12),
                Expanded(child: _Shimmer(height: 80, radius: 14)),
                const SizedBox(width: 12),
                Expanded(child: _Shimmer(height: 80, radius: 14)),
              ]),
              const SizedBox(height: 28),
              _Shimmer(width: 120, height: 16),
              const SizedBox(height: 12),
              _Shimmer(width: double.infinity, height: 76, radius: 14),
              const SizedBox(height: 10),
              _Shimmer(width: double.infinity, height: 76, radius: 14),
              const SizedBox(height: 10),
              _Shimmer(width: double.infinity, height: 76, radius: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Shimmer({this.width, required this.height, this.radius = 8});

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
class _HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _HomeErrorView({required this.message, required this.onRetry});

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
            Text('No Internet Connection',
                style: AppTextTheme.displaySmall),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}