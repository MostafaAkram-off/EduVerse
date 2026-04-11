import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'payment_receipt_screen.dart';

class EnrollConfirmScreen extends StatefulWidget {
  const EnrollConfirmScreen({super.key, required this.course});

  final CourseModel course;

  @override
  State<EnrollConfirmScreen> createState() => _EnrollConfirmScreenState();
}

class _EnrollConfirmScreenState extends State<EnrollConfirmScreen> {
  int _method = 0;

  double get _discount => widget.course.price * 0.1;
  double get _total => widget.course.price - _discount;

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Enroll',
          style: AppTextTheme.displaySmall.copyWith(fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: c.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.menu_book_rounded,
                                color: c.color, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.title, style: AppTextTheme.cardTitle),
                                Text(
                                  'by ${c.instructor}',
                                  style: AppTextTheme.cardSubtitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28, color: AppColors.borderLight),
                      _RowLine('Duration', c.duration),
                      _RowLine('Level', c.level),
                      _RowLine('Sessions', '24 sessions'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment method',
                        style: AppTextTheme.displaySmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(3, (i) {
                        final labels = [
                          'Credit / Debit Card',
                          'Bank Transfer',
                          'Installments (3 months)',
                        ];
                        return _MethodRow(
                          label: labels[i],
                          selected: _method == i,
                          onTap: () => setState(() => _method = i),
                          showDivider: i > 0,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order summary',
                        style: AppTextTheme.displaySmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      _RowLine('Course Price', '\$${c.price.toStringAsFixed(0)}'),
                      _RowLine(
                        'Discount (10%)',
                        '-\$${_discount.toStringAsFixed(0)}',
                        valueColor: AppColors.success,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextTheme.displaySmall.copyWith(fontSize: 15)),
                          Text(
                            '\$${_total.toStringAsFixed(0)}',
                            style: AppTextTheme.price.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentReceiptScreen(course: c, totalPaid: _total),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Confirm enrollment & pay'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _RowLine(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodySmall),
          Text(
            value,
            style: AppTextTheme.bodySemibold.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  const _MethodRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) const Divider(height: 1, color: AppColors.borderLight),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    color: selected ? AppColors.primary : Colors.white,
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextTheme.bodyMedium.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.payment_rounded,
                    color: AppColors.textTertiary, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
