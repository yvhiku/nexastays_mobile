import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class WalkthroughVideoPlayer extends StatefulWidget {
  const WalkthroughVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.isPlaying,
    required this.onTogglePlay,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final bool isPlaying;
  final VoidCallback onTogglePlay;

  @override
  State<WalkthroughVideoPlayer> createState() => _WalkthroughVideoPlayerState();
}

class _WalkthroughVideoPlayerState extends State<WalkthroughVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      // Listen to position changes to sync UI
      _controller.addListener(() {
        if (mounted) setState(() {});
      });

      if (widget.isPlaying) {
        _controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void didUpdateWidget(WalkthroughVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initVideo();
    } else if (_isInitialized) {
      if (widget.isPlaying && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isPlaying && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          initialPosition: _controller.value.position,
        ),
      ),
    ).then((returnedPosition) {
      // Sync position when returning from fullscreen
      if (returnedPosition is Duration && _isInitialized) {
        _controller.seekTo(returnedPosition);
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Video Container ──
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Thumbnail Background
              if (!_isInitialized || !widget.isPlaying && _controller.value.position == Duration.zero)
                if (widget.thumbnailUrl != null)
                  CachedNetworkImage(
                    imageUrl: widget.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ),

              // 2. Video Player
              if (_isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),

              // 3. Dark Overlay (if not playing or not initialized)
              if (!widget.isPlaying || !_isInitialized)
                Container(
                  color: Colors.black.withOpacity(0.35),
                ),

              // 4. Play Button (Center)
              if (!widget.isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: widget.onTogglePlay,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFFE8507A),
                        size: 30,
                      ),
                    ),
                  ),
                ),

              // 5. Top Left Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '🎥 Verified Walkthrough',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 6. Playing state: Bottom controls
              if (widget.isPlaying && _isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFFE8507A),
                            bufferedColor: Color(0xFFFFB3C1),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onTogglePlay,
                              child: const Icon(Icons.pause, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _openFullscreen(context),
                              child: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),

        // ── Note Card Below Player ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F5),
            border: Border.all(color: const Color(0xFFFFB3C1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This video was recorded by the host following Nexa's verified sequence: face · door · full walkthrough.",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: const Color(0xFF7C3AED),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fullscreen Video Player Overlay ──

class _FullscreenVideoPlayer extends StatefulWidget {
  const _FullscreenVideoPlayer({
    required this.videoUrl,
    required this.initialPosition,
  });

  final String videoUrl;
  final Duration initialPosition;

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      await _controller.seekTo(widget.initialPosition);
      setState(() {
        _isInitialized = true;
      });
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
      _controller.play();
    } catch (e) {
      debugPrint('Fullscreen error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Color(0xFFE8507A))),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(_controller.value.position);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Bottom controls
            if (_isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFE8507A),
                          bufferedColor: Color(0xFFFFB3C1),
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            child: Icon(
                              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
