import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/catalog/widgets/fallback_image.dart';

/// Widget for displaying a product image gallery
class ImageGallery extends StatefulWidget {
  final List<String> images;

  const ImageGallery({
    super.key,
    required this.images,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Column(
      children: [
        // Main image
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Show full screen image viewer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                        images: widget.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: FallbackImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.image_not_supported,
                  fallbackIconSize: 64,
                ),
              );
            },
          ),
        ),

        // Thumbnail indicators
        if (widget.images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.goldDark : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: FallbackImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.image_not_supported,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Build placeholder for missing images
  Widget _buildPlaceholder() {
    return SizedBox(
      height: 300,
      child: FallbackImage(
        imageUrl: '',
        fallbackIcon: Icons.image_not_supported,
        fallbackIconSize: 64,
        backgroundColor: Colors.grey[300],
        fallbackIconColor: Colors.grey,
      ),
    );
  }
}

/// Full screen image viewer
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: FallbackImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                fallbackIcon: Icons.image_not_supported,
                fallbackIconSize: 64,
                backgroundColor: Colors.grey[900],
                fallbackIconColor: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
