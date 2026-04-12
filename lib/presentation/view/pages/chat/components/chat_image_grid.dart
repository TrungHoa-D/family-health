import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/view/widgets/image_preview_popup.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị layout ảnh trong chat bubble.
///
/// Layout:
/// - 1 ảnh: hình chữ nhật bo tròn (tỉ lệ 4:3)
/// - 2 ảnh: 2 hình vuông nằm ngang
/// - 3 ảnh: 2 hình vuông hàng trên + 1 hình chữ nhật hàng dưới
/// - 4 ảnh: grid 2x2 hình vuông
/// - 5 ảnh: 2 hình vuông hàng trên + 3 hình vuông nhỏ hàng dưới
class ChatImageGrid extends StatelessWidget {
  const ChatImageGrid({
    super.key,
    required this.imageUrls,
    this.maxWidth = 240,
  });

  final List<String> imageUrls;
  final double maxWidth;

  static const double _gap = 3.0;
  static const double _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final count = imageUrls.length.clamp(1, 5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        width: maxWidth,
        child: _buildLayout(context, count),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, int count) {
    switch (count) {
      case 1:
        return _buildSingleImage(context);
      case 2:
        return _buildTwoImages(context);
      case 3:
        return _buildThreeImages(context);
      case 4:
        return _buildFourImages(context);
      default:
        return _buildFiveImages(context);
    }
  }

  /// 1 ảnh: hình chữ nhật tỉ lệ 4:3
  Widget _buildSingleImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: _imageWidget(context, 0),
    );
  }

  /// 2 ảnh: 2 hình vuông nằm ngang
  Widget _buildTwoImages(BuildContext context) {
    final side = (maxWidth - _gap) / 2;
    return Row(
      children: [
        SizedBox(width: side, height: side, child: _imageWidget(context, 0)),
        const SizedBox(width: _gap),
        SizedBox(width: side, height: side, child: _imageWidget(context, 1)),
      ],
    );
  }

  /// 3 ảnh: 2 hình vuông hàng trên + 1 hình chữ nhật hàng dưới
  Widget _buildThreeImages(BuildContext context) {
    final side = (maxWidth - _gap) / 2;
    final rectHeight = maxWidth * 0.45;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 0)),
            const SizedBox(width: _gap),
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 1)),
          ],
        ),
        const SizedBox(height: _gap),
        SizedBox(
          width: maxWidth,
          height: rectHeight,
          child: _imageWidget(context, 2),
        ),
      ],
    );
  }

  /// 4 ảnh: grid 2x2
  Widget _buildFourImages(BuildContext context) {
    final side = (maxWidth - _gap) / 2;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 0)),
            const SizedBox(width: _gap),
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 1)),
          ],
        ),
        const SizedBox(height: _gap),
        Row(
          children: [
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 2)),
            const SizedBox(width: _gap),
            SizedBox(
                width: side, height: side, child: _imageWidget(context, 3)),
          ],
        ),
      ],
    );
  }

  /// 5 ảnh: 2 hình vuông hàng trên + 3 hình vuông nhỏ hàng dưới
  Widget _buildFiveImages(BuildContext context) {
    final topSide = (maxWidth - _gap) / 2;
    final botSide = (maxWidth - _gap * 2) / 3;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: topSide,
                height: topSide,
                child: _imageWidget(context, 0)),
            const SizedBox(width: _gap),
            SizedBox(
                width: topSide,
                height: topSide,
                child: _imageWidget(context, 1)),
          ],
        ),
        const SizedBox(height: _gap),
        Row(
          children: [
            SizedBox(
                width: botSide,
                height: botSide,
                child: _imageWidget(context, 2)),
            const SizedBox(width: _gap),
            SizedBox(
                width: botSide,
                height: botSide,
                child: _imageWidget(context, 3)),
            const SizedBox(width: _gap),
            SizedBox(
                width: botSide,
                height: botSide,
                child: _imageWidget(context, 4)),
          ],
        ),
      ],
    );
  }

  Widget _imageWidget(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => ImagePreviewPopup.showMultiple(context, imageUrls, index),
      child: CachedNetworkImage(
        imageUrl: imageUrls[index],
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.broken_image, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
