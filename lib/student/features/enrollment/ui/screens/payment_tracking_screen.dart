import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

// ─── Local model ─────────────────────────────────────────────────────────────

enum _PayStatus { paid, pending, upcoming }

class _PayItem {
  final String id;
  final String courseTitle;
  final double amount;
  final String dateLabel;
  final String methodLabel;
  final _PayStatus status;
  final String? receiptId;

  const _PayItem({
    required this.id,
    required this.courseTitle,
    required this.amount,
    required this.dateLabel,
    required this.methodLabel,
    required this.status,
    this.receiptId,
  });

  factory _PayItem.fromJson(Map<String, dynamic> json) {
    // Parse amount
    final amount = (json['amount'] ?? json['totalAmount'] ?? json['price'] ?? 0)
        as num;

    // Parse course title
    final courseTitle = json['courseName']?.toString() ??
        json['courseTitle']?.toString() ??
        (json['course'] as Map<String, dynamic>?)?['title']?.toString() ??
        'Course';

    // Parse date
    final rawDate = json['createdAt']?.toString() ??
        json['paymentDate']?.toString() ??
        json['paidAt']?.toString() ??
        '';
    final dateLabel = _fmtDate(rawDate);

    // Parse method
    final methodLabel = json['paymentMethod']?.toString() ??
        json['method']?.toString() ??
        json['cardInfo']?.toString() ??
        'Online';

    // Parse status
    final rawStatus = (json['status']?.toString() ?? 'paid').toLowerCase();
    final status = rawStatus.contains('paid') || rawStatus.contains('success') || rawStatus.contains('completed')
        ? _PayStatus.paid
        : rawStatus.contains('pending') || rawStatus.contains('due')
            ? _PayStatus.pending
            : _PayStatus.upcoming;

    // Parse receipt
    final receiptId = json['receiptId']?.toString() ??
        json['receiptNumber']?.toString() ??
        json['transactionId']?.toString();

    return _PayItem(
      id: json['id']?.toString() ?? '',
      courseTitle: courseTitle,
      amount: amount.toDouble(),
      dateLabel: dateLabel,
      methodLabel: methodLabel,
      status: status,
      receiptId: receiptId,
    );
  }
}

String _fmtDate(String raw) {
  if (raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw).toLocal();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw;
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class PaymentTrackingScreen extends StatefulWidget {
  const PaymentTrackingScreen({super.key});

  @override
  State<PaymentTrackingScreen> createState() => _PaymentTrackingScreenState();
}

class _PaymentTrackingScreenState extends State<PaymentTrackingScreen> {
  List<_PayItem>? _items;
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
      final res = await dio.get<dynamic>(ApiEndpoints.myPayments);
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['payments'] ?? raw['transactions'] ?? []) as List)
              : <dynamic>[];
      setState(() {
        _items = list
            .map((e) => _PayItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load payments.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment tracking',
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
              child: Icon(Icons.receipt_long_outlined,
                  size: 36, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            Text('No payments yet',
                style: AppTextTheme.displaySmall.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Your transactions will appear here.',
                style: AppTextTheme.bodySmall),
          ],
        ),
      );
    }

    final paid = _items!.where((p) => p.status == _PayStatus.paid).toList();
    final totalPaid = paid.fold<double>(0, (s, p) => s + p.amount);
    final due = _items!
        .where((p) => p.status != _PayStatus.paid)
        .fold<double>(0, (s, p) => s + p.amount);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradient1Start, AppColors.gradient1End],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL SPENT',
                  style: AppTextTheme.badgeSm.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalPaid.toStringAsFixed(0)}',
                  style: AppTextTheme.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _BannerStat(
                      value: '\$${due.toStringAsFixed(0)}',
                      label: 'Upcoming due',
                    ),
                    _VertDivider(),
                    _BannerStat(
                      value: '${paid.length}',
                      label: 'Transactions',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'All transactions',
            style: AppTextTheme.displaySmall.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),

          ..._items!.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentTile(item: p),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String value;
  final String label;
  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextTheme.displaySmall
                  .copyWith(color: Colors.white, fontSize: 16)),
          Text(label,
              style: AppTextTheme.timestamp.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white24,
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final _PayItem item;
  const _PaymentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (item.status) {
      _PayStatus.paid     => (AppColors.success.withValues(alpha: 0.12), AppColors.success, 'Paid'),
      _PayStatus.pending  => (AppColors.warning.withValues(alpha: 0.12), AppColors.warning, 'Due soon'),
      _PayStatus.upcoming => (context.borderLight, context.textTertiary, 'Upcoming'),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payment_rounded, color: fg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.courseTitle, style: AppTextTheme.bodySemibold),
                const SizedBox(height: 2),
                Text(
                  [item.methodLabel, item.dateLabel]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: AppTextTheme.timestamp,
                ),
                if (item.receiptId != null && item.receiptId!.isNotEmpty)
                  Text(
                    item.receiptId!,
                    style: AppTextTheme.timestamp.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.amount.toStringAsFixed(0)}',
                style: AppTextTheme.bodySemibold.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style:
                      AppTextTheme.badgeSm.copyWith(color: fg, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
