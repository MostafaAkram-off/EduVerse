import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'certificates_screen.dart';

// PdfColor helpers — PdfColor(r, g, b, alpha) where all values are 0.0–1.0
const _pdfPrimary   = PdfColor(0.290, 0.424, 0.969);   // #4A6CF7
const _pdfSecondary = PdfColor(0.486, 0.227, 0.929);   // #7C3AED
const _pdfGold      = PdfColor(1.0,   0.843, 0.0);     // #FFD700
const _pdfWhite     = PdfColors.white;
const _pdfW75       = PdfColor(1, 1, 1, 0.75);
const _pdfW70       = PdfColor(1, 1, 1, 0.70);
const _pdfW60       = PdfColor(1, 1, 1, 0.60);
const _pdfW50       = PdfColor(1, 1, 1, 0.50);
const _pdfW25       = PdfColor(1, 1, 1, 0.25);
const _pdfW10       = PdfColor(1, 1, 1, 0.10);
const _pdfW07       = PdfColor(1, 1, 1, 0.07);
const _pdfW05       = PdfColor(1, 1, 1, 0.05);

Future<void> _generateAndSharePdf(CertItem item, String studentName) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(
        children: [
          // Background gradient
          pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_pdfPrimary, _pdfSecondary],
              ),
            ),
          ),
          // Decorative circle top-right
          pw.Positioned(
            top: -60,
            right: -60,
            child: pw.Container(
              width: 220,
              height: 220,
              decoration: const pw.BoxDecoration(
                color: _pdfW07,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          // Decorative circle bottom-left
          pw.Positioned(
            bottom: -80,
            left: -80,
            child: pw.Container(
              width: 260,
              height: 260,
              decoration: const pw.BoxDecoration(
                color: _pdfW05,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          // Inner glass card
          pw.Center(
            child: pw.Container(
              width: 560,
              padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 36),
              decoration: const pw.BoxDecoration(
                color: _pdfW10,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(20)),
                border: pw.Border(
                  top:    pw.BorderSide(color: _pdfW25, width: 1.5),
                  bottom: pw.BorderSide(color: _pdfW25, width: 1.5),
                  left:   pw.BorderSide(color: _pdfW25, width: 1.5),
                  right:  pw.BorderSide(color: _pdfW25, width: 1.5),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  // Brand row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 10, height: 10,
                        decoration: const pw.BoxDecoration(
                          color: _pdfGold, shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'E D U V E R S E',
                        style: pw.TextStyle(
                          color: _pdfWhite,
                          fontSize: 13,
                          letterSpacing: 4,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        width: 10, height: 10,
                        decoration: const pw.BoxDecoration(
                          color: _pdfGold, shape: pw.BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'CERTIFICATE OF COMPLETION',
                    style: pw.TextStyle(
                      color: _pdfW75,
                      fontSize: 9,
                      letterSpacing: 2.5,
                    ),
                  ),
                  pw.SizedBox(height: 28),
                  pw.Divider(color: _pdfW25, thickness: 0.5),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'This certifies that',
                    style: pw.TextStyle(color: _pdfW70, fontSize: 12),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    studentName,
                    style: pw.TextStyle(
                      color: _pdfWhite,
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'has successfully completed',
                    style: pw.TextStyle(color: _pdfW70, fontSize: 12),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    item.title,
                    style: pw.TextStyle(
                      color: _pdfGold,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 24),
                  pw.Divider(color: _pdfW25, thickness: 0.5),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.instructor.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Instructor',
                                style: pw.TextStyle(color: _pdfW60, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(item.instructor,
                                style: pw.TextStyle(color: _pdfWhite, fontSize: 11,
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        )
                      else
                        pw.SizedBox(),
                      if (item.date.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('Issue Date',
                                style: pw.TextStyle(color: _pdfW60, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(item.date,
                                style: pw.TextStyle(color: _pdfWhite, fontSize: 11,
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        )
                      else
                        pw.SizedBox(),
                    ],
                  ),
                  if (item.id.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Certificate ID: ${item.id}',
                      style: pw.TextStyle(color: _pdfW50, fontSize: 8),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'EduVerse_Certificate_${item.title.replaceAll(' ', '_')}.pdf',
  );
}

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key, required this.item});

  final CertItem item;

  @override
  Widget build(BuildContext context) {
    final studentName = AppPreferences.instance.userName.isNotEmpty
        ? AppPreferences.instance.userName
        : 'Student';
    final certItem = item;
    final name = studentName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        title: Text('Certificate', style: AppTextTheme.displaySmall.copyWith(fontSize: 17)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EDUVERSE',
                                style: AppTextTheme.badgeSm.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Training Center',
                                style: AppTextTheme.bodySmall
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'CERTIFICATE OF COMPLETION',
                        style: AppTextTheme.badgeSm.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.4,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This certifies that',
                        style: AppTextTheme.timestamp.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studentName,
                        style: AppTextTheme.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'has successfully completed',
                        style: AppTextTheme.timestamp.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: AppTextTheme.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.instructor.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Instructor',
                                  style: AppTextTheme.timestamp
                                      .copyWith(color: Colors.white60),
                                ),
                                Text(
                                  item.instructor,
                                  style: AppTextTheme.bodySemibold
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          if (item.date.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Issue Date',
                                  style: AppTextTheme.timestamp
                                      .copyWith(color: Colors.white60),
                                ),
                                Text(
                                  item.date,
                                  style: AppTextTheme.bodySemibold
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(item: item),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: AppColors.success, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Certificate',
                        style: AppTextTheme.bodySemibold
                            .copyWith(color: AppColors.success),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Digital credential issued by EduVerse.',
                        style: AppTextTheme.timestamp
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DownloadPdfButton(item: certItem, studentName: name),
        ],
      ),
    );
  }
}

class _DownloadPdfButton extends StatefulWidget {
  const _DownloadPdfButton({required this.item, required this.studentName});
  final CertItem item;
  final String studentName;

  @override
  State<_DownloadPdfButton> createState() => _DownloadPdfButtonState();
}

class _DownloadPdfButtonState extends State<_DownloadPdfButton> {
  bool _generating = false;

  Future<void> _download() async {
    setState(() => _generating = true);
    try {
      await _generateAndSharePdf(widget.item, widget.studentName);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _generating ? null : _download,
      icon: _generating
          ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.download_rounded, size: 20),
      label: Text(_generating ? 'Generating...' : 'Download PDF'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CertItem item;
  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      if (item.id.isNotEmpty) ['Certificate ID', item.id],
      ['Course', item.title],
      if (item.instructor.isNotEmpty) ['Instructor', item.instructor],
      if (item.date.isNotEmpty) ['Issue Date', item.date],
      ['Validity', 'Lifetime'],
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certificate information',
            style: AppTextTheme.displaySmall.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(r[0], style: AppTextTheme.bodySmall),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        r[1],
                        style: AppTextTheme.bodySemibold,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
