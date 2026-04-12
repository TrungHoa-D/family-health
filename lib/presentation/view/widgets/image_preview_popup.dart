import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:flutter/material.dart';

/// Popup toàn màn hình hiển thị ảnh với zoom (InteractiveViewer).
/// Dùng chung (common) cho toàn bộ app.
class ImagePreviewPopup extends StatefulWidget {
  const ImagePreviewPopup._({
    required this.imageUrls,
    required this.initialIndex,
    this.localFiles,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final List<File>? localFiles;

  /// Hiển thị popup cho 1 ảnh network.
  static void show(BuildContext context, String imageUrl) {
    showMultiple(context, [imageUrl], 0);
  }

  /// Hiển thị popup cho nhiều ảnh network với swipe.
  static void showMultiple(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImagePreviewPopup._(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
    );
  }

  /// Hiển thị popup cho ảnh local (File).
  static void showLocalFile(BuildContext context, File file) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImagePreviewPopup._(
              imageUrls: const [],
              initialIndex: 0,
              localFiles: [file],
            ),
          );
        },
      ),
    );
  }

  @override
  State<ImagePreviewPopup> createState() => _ImagePreviewPopupState();
}

class _ImagePreviewPopupState extends State<ImagePreviewPopup> {
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

  int get _totalCount =>
      widget.localFiles?.length ?? widget.imageUrls.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tap background to close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // Page view for images
          PageView.builder(
            controller: _pageController,
            itemCount: _totalCount,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: _buildImage(index),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Page indicator
          if (_totalCount > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalCount, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(int index) {
    if (widget.localFiles != null && widget.localFiles!.isNotEmpty) {
      return Image.file(
        widget.localFiles![index],
        fit: BoxFit.contain,
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrls[index],
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image, color: AppColors.white, size: 48),
      ),
    );
  }
}
