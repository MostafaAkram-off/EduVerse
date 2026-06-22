import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'package:edu_verse/student/features/home/ui/cubit/home_cubit.dart';
import 'package:edu_verse/student/features/learning/ui/cubit/learning_cubit.dart';

class PaymentReceiptScreen extends StatefulWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.course,
    required this.totalPaid,
    this.paymentMethod = 'Credit / Debit Card',
  });

  final CourseModel course;
  final double totalPaid;
  final String paymentMethod;

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  bool _generatingPdf = false;

  String get _receiptId {
    final hash = (widget.course.id.hashCode ^ DateTime.now().millisecondsSinceEpoch)
        .abs()
        .toString()
        .substring(0, 4);
    return '#EDU-${DateTime.now().year}-$hash';
  }

  String get _todayLabel {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _downloadPdf() async {
    setState(() => _generatingPdf = true);
    try {
      const primary = PdfColor(0.290, 0.424, 0.969);
      const success = PdfColor(0.133, 0.773, 0.369);
      const white = PdfColors.white;
      const grey = PdfColor(0.4, 0.4, 0.4);

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.Container(
            color: primary,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(40, 40, 40, 28),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('EDUVERSE', style: pw.TextStyle(color: white, fontSize: 22, fontWeight: pw.FontWeight.bold, letterSpacing: 3)),
                      pw.SizedBox(height: 4),
                      pw.Text('PAYMENT RECEIPT', style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.65), fontSize: 10, letterSpacing: 1.5)),
                    ],
                  ),
                ),
                // Body card
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.fromLTRB(24, 0, 24, 24),
                    padding: const pw.EdgeInsets.all(32),
                    decoration: const pw.BoxDecoration(
                      color: white,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Success badge
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: const pw.BoxDecoration(
                            color: PdfColor(0.133, 0.773, 0.369, 0.15),
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          child: pw.Text('PAYMENT CONFIRMED', style: pw.TextStyle(color: success, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text('${widget.totalPaid.toStringAsFixed(0)} EGP',
                            style: pw.TextStyle(color: primary, fontSize: 36, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Total amount paid', style: pw.TextStyle(color: grey, fontSize: 12)),
                        pw.SizedBox(height: 24),
                        pw.Divider(color: PdfColor(0.9, 0.9, 0.9)),
                        pw.SizedBox(height: 20),
                        _pdfRow('Receipt No.', _receiptId),
                        _pdfRow('Course', widget.course.title),
                        _pdfRow('Amount Paid', '${widget.totalPaid.toStringAsFixed(0)} EGP'),
                        _pdfRow('Payment Date', _todayLabel),
                        _pdfRow('Method', widget.paymentMethod),
                        _pdfRow('Status', 'Confirmed'),
                        pw.SizedBox(height: 24),
                        pw.Divider(color: PdfColor(0.9, 0.9, 0.9)),
                        pw.SizedBox(height: 16),
                        pw.Text('Thank you for choosing EduVerse!',
                            style: pw.TextStyle(color: grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'EduVerse_Receipt_${widget.course.title.replaceAll(' ', '_')}.pdf',
      );
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: const PdfColor(0.4, 0.4, 0.4), fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
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
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
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
                          color: context.textTertiary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Line('Receipt No.', _receiptId),
                      _Line('Course', widget.course.title),
                      _Line('Amount Paid', '${widget.totalPaid.toStringAsFixed(0)} EGP'),
                      _Line('Payment Date', _todayLabel),
                      _Line('Method', widget.paymentMethod),
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
                        onPressed: _generatingPdf ? null : _downloadPdf,
                        icon: _generatingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download_rounded, size: 18),
                        label: Text(_generatingPdf ? 'Generating...' : 'Download PDF'),
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
                        onPressed: () {
                          final text =
                              'EduVerse Receipt\n'
                              'Course: ${widget.course.title}\n'
                              'Amount: ${widget.totalPaid.toStringAsFixed(0)} EGP\n'
                              'Method: ${widget.paymentMethod}\n'
                              'Date: $_todayLabel\n'
                              'Receipt: $_receiptId';
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Copy'),
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
              onPressed: () {
                GetIt.instance<HomeCubit>().loadHome();
                GetIt.instance<LearningCubit>().loadLearning();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
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
