import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'certificate_detail_screen.dart';

class CertItem {
  final String id;
  final String courseId;
  final String title;
  final String instructor;
  final String date;

  CertItem({
    required this.id,
    required this.courseId,
    required this.title,
    required this.instructor,
    required this.date,
  });

  factory CertItem.fromJson(Map<String, dynamic> json) {
    final issuedAt = json['issuedAt']?.toString() ?? json['issueDate']?.toString() ?? '';
    String dateLabel = issuedAt;
    if (issuedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(issuedAt);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        dateLabel = '${months[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }
    return CertItem(
      id: json['id']?.toString() ?? json['certificateId']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['courseName']?.toString() ??
          json['courseTitle']?.toString() ??
          json['title']?.toString() ??
          'Certificate',
      instructor: json['instructorName']?.toString() ??
          json['instructor']?.toString() ??
          '',
      date: dateLabel,
    );
  }

  static const List<Color> _palette = [
    Color(0xFF7C3AED),
    Color(0xFF0EA5E9),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF4A6CF7),
  ];

  Color get color => _palette[id.hashCode.abs() % _palette.length];
}

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<CertItem>? _items;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = GetIt.instance<Dio>();
      final res = await dio.get<dynamic>(ApiEndpoints.myCertificates);
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['certificates'] ?? []) as List)
              : <dynamic>[];
      setState(() {
        _items = list
            .map((e) => CertItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load certificates.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: canPop
          ? AppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Certificates', style: AppTextTheme.screenTitle),
                    const SizedBox(height: 4),
                    Text('Your verified achievements', style: AppTextTheme.bodySmall),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildBody(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items == null || _items!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_outlined,
                  size: 36, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            Text('No certificates yet',
                style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Complete a course to earn your first certificate.',
                style: AppTextTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _items!.map((cert) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _CertificateCard(
            item: cert,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CertificateDetailScreen(item: cert),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertItem item;
  final VoidCallback onTap;

  const _CertificateCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [item.color, item.color.withValues(alpha: 0.75)],
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'CERTIFICATE OF COMPLETION',
                          style: AppTextTheme.badgeSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: AppTextTheme.displaySmall.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    if (item.instructor.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Instructor: ${item.instructor}',
                        style: AppTextTheme.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.id}${item.date.isNotEmpty ? ' · ${item.date}' : ''}',
                            style: AppTextTheme.timestamp.copyWith(color: Colors.white60),
                          ),
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          onPressed: onTap,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Open'),
                            ],
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
      ),
    );
  }
}
