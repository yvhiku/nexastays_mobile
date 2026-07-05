import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.photoUrls,
    required this.isVerified,
    this.initialIndex = 0,
  });

  final List<String> photoUrls;
  final bool isVerified;
  final int initialIndex;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullscreenGallery(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenGalleryOverlay(
          photoUrls: widget.photoUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        // ── Main Carousel ────────────────────────────────────────────────
        PageView.builder(
          controller: _pageController,
          itemCount: widget.photoUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final url = widget.photoUrls[index];
            return GestureDetector(
              onTap: () => _openFullscreenGallery(context, index),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            );
          },
        ),

        // ── Verified overlay (top left) ──────────────────────────────────
        if (widget.isVerified)
          Positioned(
            top: 12 + MediaQuery.of(context).padding.top + kToolbarHeight - 20, // Adjust for sliver app bar
            left: 12,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8507A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✓ Verified',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // ── Photo counter badge (top right) ──────────────────────────────
        Positioned(
          top: 12 + MediaQuery.of(context).padding.top + kToolbarHeight - 20,
          right: 12,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.photoUrls.length}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // ── Dots Indicator (bottom center) ───────────────────────────────
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.photoUrls.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Fullscreen Gallery Overlay (Simple implementation) ──────────────────────

class _FullscreenGalleryOverlay extends StatefulWidget {
  const _FullscreenGalleryOverlay({
    required this.photoUrls,
    required this.initialIndex,
  });

  final List<String> photoUrls;
  final int initialIndex;

  @override
  State<_FullscreenGalleryOverlay> createState() =>
      _FullscreenGalleryOverlayState();
}

class _FullscreenGalleryOverlayState extends State<_FullscreenGalleryOverlay> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photoUrls.length}',
          style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: widget.photoUrls[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}
