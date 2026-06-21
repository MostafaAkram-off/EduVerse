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
  double _speed = 1.0;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  Future<void> _setup() async {
    if (!mounted) return;
    setState(() => _error = null);

    try {
      final dio = GetIt.instance<Dio>();
      final sasPath = widget.url.replaceFirst('/Cloud/Get/', '/Cloud/GetSas/');
      final res = await dio.get<dynamic>(sasPath);
      final data = res.data;

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

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      await _player.open(Media(sasUrl));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _retry() {
    setState(() => _error = null);
    _setup();
  }

  void _seek(int seconds) {
    final pos = _player.state.position;
    final next = pos + Duration(seconds: seconds);
    _player.seek(next.isNegative ? Duration.zero : next);
  }

  void _setSpeed(double speed) {
    _player.setRate(speed);
    setState(() => _speed = speed);
  }

  String get _speedLabel {
    final s = _speed;
    return s == s.truncateToDouble() ? '${s.toInt()}x' : '${s}x';
  }

  MaterialVideoControlsThemeData get _controlsTheme =>
      MaterialVideoControlsThemeData(
        seekOnDoubleTap: true,
        seekOnDoubleTapBackwardDuration: const Duration(seconds: 10),
        seekOnDoubleTapForwardDuration: const Duration(seconds: 10),
        bottomButtonBar: [
          const MaterialPlayOrPauseButton(),
          MaterialCustomButton(
            onPressed: () => _seek(-10),
            icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
          ),
          MaterialCustomButton(
            onPressed: () => _seek(10),
            icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
          ),
          const MaterialPositionIndicator(),
          const Spacer(),
          const MaterialFullscreenButton(),
        ],
      );

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
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        title: Text(
          widget.title ?? 'Session Video',
          style: AppTextTheme.screenTitle.colored(Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<double>(
            initialValue: _speed,
            onSelected: _setSpeed,
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => _speeds
                .map((s) => PopupMenuItem<double>(
                      value: s,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s == s.truncateToDouble()
                                ? '${s.toInt()}x'
                                : '${s}x',
                            style: TextStyle(
                              color: s == _speed
                                  ? const Color(0xFF4A6CF7)
                                  : Colors.white,
                              fontWeight: s == _speed
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          if (s == _speed)
                            const Icon(Icons.check_rounded,
                                size: 16, color: Color(0xFF4A6CF7)),
                        ],
                      ),
                    ))
                .toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Text(
                _speedLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MaterialVideoControlsTheme(
            normal: _controlsTheme,
            fullscreen: _controlsTheme,
            child: Video(
              controller: _controller,
              controls: MaterialVideoControls,
            ),
          ),
          if (_error != null) _ErrorBody(message: _error!, onRetry: _retry),
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
