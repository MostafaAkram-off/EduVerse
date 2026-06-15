import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.url, this.title});

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

    // Resolve the actual playback URL.
    // The backend may redirect to an Azure SAS URL, or return a JSON body
    // containing the real URL. We probe with Dio (which carries our auth
    // interceptor) and adapt before handing the final URL to MPV.
    String urlToPlay = widget.url;
    bool needsAuthHeader = true;

    try {
      final dio = GetIt.instance<Dio>();
      final res = await dio.get<dynamic>(
        widget.url,
        options: Options(
          followRedirects: false,
          validateStatus: (_) => true,
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final code = res.statusCode ?? 0;

      if (code >= 300 && code < 400) {
        // Server redirects to storage (Azure SAS) — use Location header directly.
        final loc = res.headers.value('location') ?? '';
        if (loc.isNotEmpty) {
          urlToPlay = loc;
          needsAuthHeader = false; // SAS token is already in the query string
        }
      } else if (code == 200 && res.data is String) {
        final body = (res.data as String).trim();
        if (body.startsWith('{') || body.startsWith('[')) {
          // Server returned a JSON body — extract the video URL from it.
          final data = jsonDecode(body);
          if (data is Map) {
            final extracted = (data['url'] ??
                    data['fileUrl'] ??
                    data['sasUrl'] ??
                    data['videoUrl'] ??
                    data['blobUrl'] ??
                    data['link']) as String?;
            if (extracted != null && extracted.isNotEmpty) {
              urlToPlay = extracted;
              needsAuthHeader = !extracted.contains('sig=');
            }
          }
        }
        // If body is not JSON (binary bytes mis-decoded as plain text),
        // fall through and play the original URL directly.
      }
    } catch (_) {
      // Probe failed — proceed with original URL and auth header.
    }

    if (_player.platform is NativePlayer) {
      final np = _player.platform as NativePlayer;
      await np.setProperty('force-seekable', 'yes');
      await np.setProperty('demuxer-seekable-cache', 'yes');
    }

    if (!mounted) return;
    await _player.open(
      Media(
        urlToPlay,
        httpHeaders: {
          if (needsAuthHeader &&
              AuthSession.token != null &&
              urlToPlay.contains(ApiEndpoints.baseUrl))
            'Authorization': 'Bearer ${AuthSession.token}',
        },
      ),
    );
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
      body: _error != null
          ? _ErrorBody(message: _error!, onRetry: _retry)
          : Video(
              controller: _controller,
              controls: MaterialVideoControls,
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
