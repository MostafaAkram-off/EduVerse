import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'package:edu_verse/student/features/home/ui/cubit/home_cubit.dart';
import 'package:edu_verse/student/features/learning/ui/cubit/learning_cubit.dart';
import 'package:edu_verse/student/features/enrollment/ui/screens/payment_receipt_screen.dart';

enum _Stage { select, loading, launched, error }

class EnrollConfirmScreen extends StatefulWidget {
  const EnrollConfirmScreen({super.key, required this.course});
  final CourseModel course;

  @override
  State<EnrollConfirmScreen> createState() => _EnrollConfirmScreenState();
}

class _EnrollConfirmScreenState extends State<EnrollConfirmScreen> {
  int _method = 0;
  _Stage _stage = _Stage.select;
  String? _errorMsg;

  // Must match what the backend expects for /User/payment/{courseId}/{method}
  static const _methodKeys = ['card', 'bank_transfer', 'installments'];

  double get _discount => widget.course.price * 0.1;
  double get _total    => widget.course.price - _discount;

  Future<void> _confirm() async {
    setState(() { _stage = _Stage.loading; _errorMsg = null; });
    try {
      final dio = GetIt.instance<Dio>();

      // Enroll first (silent fail — server is idempotent)
      try { await dio.post<dynamic>(ApiEndpoints.enroll(widget.course.id)); } catch (_) {}

      // Get PayMob checkout URL from backend
      final res = await dio.post<dynamic>(
        ApiEndpoints.payment(widget.course.id, _methodKeys[_method]),
      );

      // API returns the URL as a plain string body
      final data = res.data;
      String? url;
      if (data is String) {
        url = data.trim();
      } else if (data is Map) {
        url = data['url']?.toString() ??
              data['paymentUrl']?.toString() ??
              data['checkoutUrl']?.toString();
      }
      if (url == null || url.isEmpty) throw Exception('No payment URL in response');

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      setState(() => _stage = _Stage.launched);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _errorMsg = 'Payment failed. Please try again.';
      });
    }
  }

  void _done() {
    GetIt.instance<HomeCubit>().loadHome();
    GetIt.instance<LearningCubit>().loadLearning();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _stage == _Stage.loading ? null : () => Navigator.of(context).pop(),
        ),
        title: Text('Enroll',
            style: AppTextTheme.displaySmall.copyWith(fontSize: 17)),
      ),
      body: _stage == _Stage.launched
          ? _LaunchedBody(
              onPaid: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PaymentReceiptScreen(
                    course: widget.course,
                    totalPaid: _total,
                    paymentMethod: const [
                      'Credit / Debit Card',
                      'Bank Transfer',
                      'Installments',
                    ][_method],
                  ),
                ),
              ),
              onLater: _done,
            )
          : _SelectBody(
              course: widget.course,
              selectedMethod: _method,
              onMethodChanged: (m) => setState(() => _method = m),
              discount: _discount,
              total: _total,
              loading: _stage == _Stage.loading,
              errorMsg: _stage == _Stage.error ? _errorMsg : null,
              onConfirm: _confirm,
            ),
    );
  }
}

// ─── Payment launched state ───────────────────────────────────────────────────

class _LaunchedBody extends StatelessWidget {
  final VoidCallback onPaid;
  final VoidCallback onLater;
  const _LaunchedBody({required this.onPaid, required this.onLater});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.open_in_browser_rounded,
                        color: AppColors.primary, size: 44),
                  ),
                  const SizedBox(height: 24),
                  Text('Complete your payment',
                      style: AppTextTheme.displayMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'We opened the PayMob payment page in your browser.\n'
                    'Complete the payment there, then come back.',
                    style: AppTextTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: onPaid,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("I've paid — show my courses"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onLater,
                child: Text(
                  "I'll pay later",
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Method selection + order summary ────────────────────────────────────────

class _SelectBody extends StatelessWidget {
  final CourseModel course;
  final int selectedMethod;
  final ValueChanged<int> onMethodChanged;
  final double discount;
  final double total;
  final bool loading;
  final String? errorMsg;
  final VoidCallback onConfirm;

  const _SelectBody({
    required this.course,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.discount,
    required this.total,
    required this.loading,
    required this.errorMsg,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Course card ──────────────────────────────
              _Card(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: course.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book_rounded,
                          color: course.color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.title,
                              style: AppTextTheme.cardTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          Text('by ${course.instructor}',
                              style: AppTextTheme.cardSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Badge(course.level),
                              const SizedBox(width: 6),
                              _Badge(course.duration),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Payment method ────────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment method',
                        style: AppTextTheme.displaySmall
                            .copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    _MethodRow(
                      icon: Icons.credit_card_rounded,
                      label: 'Credit / Debit Card',
                      sublabel: 'Visa, Mastercard, Meeza',
                      selected: selectedMethod == 0,
                      onTap: () => onMethodChanged(0),
                      showDivider: false,
                    ),
                    _MethodRow(
                      icon: Icons.account_balance_rounded,
                      label: 'Bank Transfer',
                      sublabel: 'Instapay, Fawry, Aman',
                      selected: selectedMethod == 1,
                      onTap: () => onMethodChanged(1),
                      showDivider: true,
                    ),
                    _MethodRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Installments',
                      sublabel: 'Pay over 3 months, 0% interest',
                      selected: selectedMethod == 2,
                      onTap: () => onMethodChanged(2),
                      showDivider: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Order summary ─────────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order summary',
                        style: AppTextTheme.displaySmall
                            .copyWith(fontSize: 15)),
                    const SizedBox(height: 10),
                    _RowLine('Course Price',
                        '${course.price.toStringAsFixed(0)} EGP'),
                    _RowLine(
                      'Discount (10%)',
                      '-${discount.toStringAsFixed(0)} EGP',
                      valueColor: AppColors.success,
                    ),
                    Divider(height: 24, color: context.borderLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: AppTextTheme.displaySmall
                                .copyWith(fontSize: 15)),
                        Text('${total.toStringAsFixed(0)} EGP',
                            style: AppTextTheme.price
                                .copyWith(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── PayMob security badge ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 14, color: context.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    'Secured by PayMob',
                    style: AppTextTheme.timestamp
                        .copyWith(color: context.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Bottom button ──────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMsg != null) ...[
                Text(
                  errorMsg!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: loading ? null : onConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Proceed to payment'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.borderLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: AppTextTheme.timestamp.copyWith(fontSize: 10)),
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
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
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
          Text(value,
              style:
                  AppTextTheme.bodySemibold.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  const _MethodRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) Divider(height: 1, color: context.borderLight),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
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
                      color: selected ? AppColors.primary : context.border,
                      width: 2,
                    ),
                    color: selected ? AppColors.primary : context.surface,
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
                Icon(icon,
                    size: 20,
                    color: selected
                        ? AppColors.primary
                        : context.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextTheme.bodyMedium.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? context.textPrimary
                              : context.textSecondary,
                        ),
                      ),
                      Text(
                        sublabel,
                        style: AppTextTheme.timestamp
                            .copyWith(color: context.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
