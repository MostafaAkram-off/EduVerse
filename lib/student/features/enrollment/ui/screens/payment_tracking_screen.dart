import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/mock_data.dart';

class PaymentTrackingScreen extends StatelessWidget {
  const PaymentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paid = MockData.paymentLedger
        .where((p) => p.status == PaymentStatus.paid)
        .toList();
    final totalPaid =
        paid.fold<double>(0, (s, p) => s + p.amount);
    final due = MockData.paymentLedger
        .where((p) => p.status != PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amount);

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradient1Start,
                  AppColors.gradient1End,
                ],
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
                    _BannerStat(value: '\$${due.toStringAsFixed(0)}', label: 'Upcoming due'),
                    _VertDivider(),
                    _BannerStat(value: '${paid.length}', label: 'Transactions'),
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
          ...MockData.paymentLedger.map(
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
          Text(
            value,
            style: AppTextTheme.displaySmall.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTextTheme.timestamp.copyWith(color: Colors.white70),
          ),
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
  final PaymentLedgerItem item;
  const _PaymentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (item.status) {
      PaymentStatus.paid => (
          AppColors.successLight,
          AppColors.success,
          'Paid',
        ),
      PaymentStatus.pending => (
          AppColors.warningLight,
          AppColors.warning,
          'Due soon',
        ),
      PaymentStatus.upcoming => (
          AppColors.borderLight,
          AppColors.textTertiary,
          'Upcoming',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                  '${item.methodLabel} · ${item.dateLabel}',
                  style: AppTextTheme.timestamp,
                ),
                if (item.receiptId != null)
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
                  style: AppTextTheme.badgeSm.copyWith(color: fg, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
