import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.course,
    required this.totalPaid,
  });

  final CourseModel course;
  final double totalPaid;

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
          'Payment receipt',
          style: AppTextTheme.displaySmall.copyWith(fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 44),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment successful!',
                      style: AppTextTheme.displayMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "You're now enrolled in the course",
                      style: AppTextTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECEIPT',
                        style: AppTextTheme.badgeSm.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Line('Receipt No.', '#EDU-2026-4821'),
                      _Line('Course', course.title),
                      _Line('Amount Paid', '\$${totalPaid.toStringAsFixed(0)}'),
                      _Line('Payment Date', 'Apr 11, 2026'),
                      _Line('Method', 'Credit Card **** 4242'),
                      _Line(
                        'Status',
                        'Confirmed',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download PDF'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: FilledButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Start learning'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Line(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodySmall),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextTheme.bodySemibold.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
