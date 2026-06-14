import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
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
  bool _loading = false;
  String? _errorMsg;

  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl  = TextEditingController();
  final _expiryCtrl      = TextEditingController();
  final _cvvCtrl         = TextEditingController();
  final _cardNameCtrl    = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  double get _discount => widget.course.price * 0.1;
  double get _total    => widget.course.price - _discount;
  double get _installment => _total / 3;

  static const _methodKeys = ['CreditCard', 'BankTransfer', 'Installments'];

  String get _receiptMethodLabel {
    if (_method == 0) {
      final raw = _cardNumberCtrl.text.replaceAll(' ', '');
      final last4 = raw.length >= 4 ? raw.substring(raw.length - 4) : '****';
      return 'Credit Card **** $last4';
    }
    if (_method == 1) return 'Bank Transfer';
    return 'Installments (3 months)';
  }

  Future<void> _confirm() async {
    // Validate card form if credit card is selected
    if (_method == 0 && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() { _loading = true; _errorMsg = null; });
    try {
      final dio = GetIt.instance<Dio>();
      try {
        await dio.post<dynamic>(ApiEndpoints.enroll(widget.course.id));
      } catch (_) {}
      await dio.post<dynamic>(
        ApiEndpoints.payment(widget.course.id, _methodKeys[_method]),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _errorMsg = 'Payment failed. Please try again.'; });
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentReceiptScreen(
          course: widget.course,
          totalPaid: _total,
          paymentMethod: _receiptMethodLabel,
        ),
      ),
    );
  }

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
        title: Text('Enroll',
            style: AppTextTheme.displaySmall.copyWith(fontSize: 17)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Course info card ──────────────────────
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
                                  Text(c.title,
                                      style: AppTextTheme.cardTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  Text('by ${c.instructor}',
                                      style: AppTextTheme.cardSubtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 28, color: context.borderLight),
                        _RowLine('Duration', c.duration),
                        _RowLine('Level', c.level),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Payment method ────────────────────────
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
                          selected: _method == 0,
                          onTap: () => setState(() => _method = 0),
                          showDivider: false,
                        ),
                        _MethodRow(
                          icon: Icons.account_balance_rounded,
                          label: 'Bank Transfer',
                          selected: _method == 1,
                          onTap: () => setState(() => _method = 1),
                          showDivider: true,
                        ),
                        _MethodRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'Installments (3 months)',
                          selected: _method == 2,
                          onTap: () => setState(() => _method = 2),
                          showDivider: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Method details (animated) ─────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => SizeTransition(
                      sizeFactor: anim,
                      axisAlignment: -1,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: switch (_method) {
                      0 => Padding(
                          key: const ValueKey(0),
                          padding: const EdgeInsets.only(top: 14),
                          child: _CardForm(
                            numberCtrl: _cardNumberCtrl,
                            expiryCtrl: _expiryCtrl,
                            cvvCtrl:    _cvvCtrl,
                            nameCtrl:   _cardNameCtrl,
                          ),
                        ),
                      1 => Padding(
                          key: const ValueKey(1),
                          padding: const EdgeInsets.only(top: 14),
                          child: _BankTransferInfo(),
                        ),
                      _ => Padding(
                          key: const ValueKey(2),
                          padding: const EdgeInsets.only(top: 14),
                          child: _InstallmentPlan(
                            installment: _installment,
                            total: _total,
                          ),
                        ),
                    },
                  ),

                  const SizedBox(height: 14),

                  // ── Order summary ─────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order summary',
                            style: AppTextTheme.displaySmall
                                .copyWith(fontSize: 15)),
                        const SizedBox(height: 10),
                        _RowLine('Course Price',
                            '\$${c.price.toStringAsFixed(0)}'),
                        _RowLine(
                          'Discount (10%)',
                          '-\$${_discount.toStringAsFixed(0)}',
                          valueColor: AppColors.success,
                        ),
                        Divider(height: 24, color: context.borderLight),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: AppTextTheme.displaySmall
                                    .copyWith(fontSize: 15)),
                            Text('\$${_total.toStringAsFixed(0)}',
                                style:
                                    AppTextTheme.price.copyWith(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom button ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  if (_errorMsg != null) ...[
                    Text(
                      _errorMsg!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: _loading ? null : _confirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirm enrollment & pay'),
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

// ─── Card form ────────────────────────────────────────────────────────────────

class _CardForm extends StatelessWidget {
  final TextEditingController numberCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final TextEditingController nameCtrl;

  const _CardForm({
    required this.numberCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.nameCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Secure card details',
                  style: AppTextTheme.labelSmall
                      .copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 14),

          // Card number
          _FieldLabel('Card Number'),
          const SizedBox(height: 6),
          TextFormField(
            controller: numberCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            maxLength: 19,
            decoration: _fieldDeco(context,
                hint: '0000  0000  0000  0000',
                icon: Icons.credit_card_rounded),
            validator: (v) {
              final digits = (v ?? '').replaceAll(' ', '');
              if (digits.length < 16) return 'Enter a valid 16-digit card number';
              return null;
            },
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              // Expiry
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Expiry Date'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: expiryCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      maxLength: 5,
                      decoration: _fieldDeco(context,
                          hint: 'MM/YY',
                          icon: Icons.calendar_today_rounded),
                      validator: (v) {
                        final clean = (v ?? '').replaceAll('/', '');
                        if (clean.length < 4) return 'Invalid date';
                        final month = int.tryParse(clean.substring(0, 2)) ?? 0;
                        if (month < 1 || month > 12) return 'Invalid month';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // CVV
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('CVV'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: cvvCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 4,
                      obscureText: true,
                      decoration: _fieldDeco(context,
                          hint: '•••',
                          icon: Icons.lock_rounded),
                      validator: (v) {
                        if ((v ?? '').length < 3) return 'Invalid CVV';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Cardholder name
          _FieldLabel('Cardholder Name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: nameCtrl,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDeco(context,
                hint: 'Name as on card',
                icon: Icons.person_outline_rounded),
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Enter cardholder name';
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(BuildContext context,
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      prefixIcon: Icon(icon, size: 18, color: context.textTertiary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      filled: true,
      fillColor: context.bg,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextTheme.labelSmall
            .copyWith(color: context.textSecondary, fontWeight: FontWeight.w600));
  }
}

// ─── Bank transfer info ───────────────────────────────────────────────────────

class _BankTransferInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Bank transfer details',
                  style: AppTextTheme.bodySemibold),
            ],
          ),
          const SizedBox(height: 14),
          _BankRow('Bank Name', 'EduVerse National Bank'),
          _BankRow('Account Number', '1234-5678-9012-3456'),
          _BankRow('SWIFT / BIC', 'EDUVEGCX'),
          _BankRow('Reference', 'EDU-PAY-${DateTime.now().millisecond}'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Transfer must be completed within 48 hours. Use the reference number above.',
                    style: AppTextTheme.labelSmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;
  const _BankRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodySmall),
          Flexible(
            child: Text(value,
                style: AppTextTheme.bodySemibold,
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ─── Installment plan ─────────────────────────────────────────────────────────

class _InstallmentPlan extends StatelessWidget {
  final double installment;
  final double total;
  const _InstallmentPlan({required this.installment, required this.total});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    String monthLabel(int offset) {
      final dt = DateTime(now.year, now.month + offset);
      return '${months[dt.month - 1]} ${dt.year}';
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Installment plan',
                  style: AppTextTheme.bodySemibold),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(3, (i) {
            final isFirst = i == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isFirst
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : context.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFirst
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : context.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.primary
                          : context.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isFirst
                              ? Colors.white
                              : context.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      monthLabel(i),
                      style: AppTextTheme.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight:
                            isFirst ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    '\$${installment.toStringAsFixed(0)}',
                    style: AppTextTheme.bodySemibold.copyWith(
                      color: isFirst
                          ? AppColors.primary
                          : context.textPrimary,
                    ),
                  ),
                  if (isFirst) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('Today',
                          style: AppTextTheme.badgeSm
                              .copyWith(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
            );
          }),
          Divider(height: 20, color: context.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextTheme.bodySemibold),
              Text('\$${total.toStringAsFixed(0)}',
                  style: AppTextTheme.bodySemibold
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Input formatters ─────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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
              style: AppTextTheme.bodySemibold.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  const _MethodRow({
    required this.icon,
    required this.label,
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
                // Radio
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
                // Icon
                Icon(icon,
                    size: 20,
                    color: selected
                        ? AppColors.primary
                        : context.textSecondary),
                const SizedBox(width: 10),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: AppTextTheme.bodyMedium.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? context.textPrimary
                          : context.textSecondary,
                    ),
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
