import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  bool isRead;
  final String createdAt;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory _NotificationItem.fromJson(Map<String, dynamic> json) {
    return _NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

String _fmtDate(String raw) {
  try {
    final dt = DateTime.parse(raw).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw;
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotificationItem>? _items;
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
      final res = await dio.get<dynamic>(ApiEndpoints.myNotifications);
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['notifications'] ?? []) as List)
              : <dynamic>[];
      setState(() {
        _items = list
            .map((e) => _NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load notifications.'; _loading = false; });
    }
  }

  Future<void> _markRead(_NotificationItem item) async {
    if (item.isRead) return;
    setState(() => item.isRead = true);
    try {
      final dio = GetIt.instance<Dio>();
      await dio.post<dynamic>(ApiEndpoints.markNotificationRead(item.id));
    } catch (_) {
      // silently ignore — UI already updated
    }
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('session') || t.contains('class')) return Icons.event_note_rounded;
    if (t.contains('grade') || t.contains('assignment') || t.contains('graded')) return Icons.grade_rounded;
    if (t.contains('cert')) return Icons.workspace_premium_rounded;
    if (t.contains('payment') || t.contains('paid')) return Icons.payment_rounded;
    return Icons.notifications_rounded;
  }

  Color _iconColor(BuildContext context, String title) {
    final t = title.toLowerCase();
    if (t.contains('session') || t.contains('class')) return AppColors.primary;
    if (t.contains('grade') || t.contains('assignment') || t.contains('graded')) return AppColors.success;
    if (t.contains('cert')) return AppColors.secondary;
    if (t.contains('payment') || t.contains('paid')) return AppColors.warning;
    return context.textTertiary;
  }

  Color _iconBg(BuildContext context, String title) {
    final t = title.toLowerCase();
    if (t.contains('session') || t.contains('class')) return AppColors.primary.withValues(alpha: 0.12);
    if (t.contains('grade') || t.contains('assignment') || t.contains('graded')) return AppColors.success.withValues(alpha: 0.12);
    if (t.contains('cert')) return const Color(0xFF8B5CF6).withValues(alpha: 0.12);
    if (t.contains('payment') || t.contains('paid')) return AppColors.warning.withValues(alpha: 0.12);
    return context.borderLight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextTheme.displaySmall.copyWith(fontSize: 17),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
              const SizedBox(height: 16),
              Text(_error!, style: AppTextTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_items == null || _items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_off_outlined,
                  size: 36, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            Text('No notifications yet', style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text("You're all caught up!", style: AppTextTheme.bodySmall),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items!.length,
        itemBuilder: (context, index) {
          final n = _items![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: n.isRead
                  ? context.surface
                  : context.isDark
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _markRead(n),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: n.isRead
                          ? context.borderLight
                          : AppColors.primary.withValues(alpha: 0.12),
                    ),
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _iconBg(context, n.title),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconFor(n.title),
                          color: _iconColor(context, n.title),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(n.title, style: AppTextTheme.bodySemibold),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: AppTextTheme.bodyMedium
                                  .copyWith(color: context.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n.createdAt.isNotEmpty ? _fmtDate(n.createdAt) : '',
                              style: AppTextTheme.timestamp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
