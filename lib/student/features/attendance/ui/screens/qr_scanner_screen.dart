import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    if (mounted) Navigator.of(context).pop<String>(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          'Scan QR code',
                          textAlign: TextAlign.center,
                          style: AppTextTheme.displaySmall.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Point your camera at the session QR code to mark attendance.',
                    textAlign: TextAlign.center,
                    style: AppTextTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: _corner(),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Transform.rotate(
                            angle: 1.5708,
                            child: _corner(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Transform.rotate(
                            angle: -1.5708,
                            child: _corner(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Transform.rotate(
                            angle: 3.14159,
                            child: _corner(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Session',
                        style: AppTextTheme.timestamp.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UI/UX Design – Session 3',
                        style: AppTextTheme.bodySemibold
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mon Mar 10 · 10:00 AM',
                        style: AppTextTheme.timestamp.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 3),
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
        ),
      ),
    );
  }
}
