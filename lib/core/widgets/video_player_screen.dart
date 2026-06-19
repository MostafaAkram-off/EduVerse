import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<String>? _errorSub;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _player = Player();
    _controller = VideoController(_player);

    _errorSub = _player.stream.error.listen((err) {
      if (mounted && err.isNotEmpty) setState(() => _error = err);
    });

    // Wait for the Video widget surface to be mounted before opening media,
    // otherwise the video decodes but frames have nowhere to render (black screen).
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  Future<void> _setup() async {
    if (!mounted) return;
    setState(() => _error = null);

    try {
      final dio = GetIt.instance<Dio>();

      // Hit /Cloud/GetSas/ to get a time-limited Azure SAS URL.
      // SAS URLs are served directly by Azure Blob with native Range Request
      // support, so seeking works without any extra MPV configuration.
      final sasPath = widget.url.replaceFirst('/Cloud/Get/', '/Cloud/GetSas/');
      final res = await dio.get<dynamic>(sasPath);
      final data = res.data;

      // Backend may return the SAS URL as a plain string or wrapped in JSON.
      String? sasUrl;
      if (data is String && data.trim().isNotEmpty) {
        sasUrl = data.trim();
      } else if (data is Map) {
        sasUrl = (data['url'] ?? data['sasUrl'] ?? data['fileUrl'] ??
            data['blobUrl'] ?? data['link']) as String?;
      }

      if (sasUrl == null || sasUrl.isEmpty) {
        throw Exception('No SAS URL returned from server');
      }

      // Give the native surface (Flutter Texture) a moment to attach
      // before opening media, to avoid a black first frame.
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      // SAS URL carries the auth signature in its query params — no Bearer header needed.
      await _player.open(Media(sasUrl));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _retry() {
    setState(() => _error = null);
    _setup();
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          widget.title ?? 'Session Video',
          style: AppTextTheme.screenTitle.colored(Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Video(controller: _controller, controls: MaterialVideoControls),
          if (_error != null)
            _ErrorBody(message: _error!, onRetry: _retry),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 52, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Could not play video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.40)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
