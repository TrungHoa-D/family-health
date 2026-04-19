import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

/// Card chọn ảnh thuốc thủ công (không AI) — dashed border, icon image
class ManualImagePickerCard extends StatelessWidget {
  const ManualImagePickerCard({
    super.key,
    this.onTap,
    this.pickedImage,
    this.imageUrl,
  });

  final VoidCallback? onTap;
  final File? pickedImage;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.textSecondary,
          strokeWidth: 1.5,
          radius: AppSpacing.radiusCard,
        ),
        child: Container(
          width: double.infinity,
          height: (pickedImage != null || imageUrl != null) ? 180 : null,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (pickedImage != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: Image.file(
              pickedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Text(
                'meds.manual_image_change'.tr(),
                style: AppStyles.labelSmall.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      );
    }

    if (imageUrl != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: Image.network(
              imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Text(
                'meds.manual_image_change'.tr(),
                style: AppStyles.labelSmall.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      );
    }

    // Empty state
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.textSecondary,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'meds.manual_image_title'.tr(),
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'meds.manual_image_desc'.tr(),
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Custom painter cho dashed border
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });
  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 10.0;
    const dashSpace = 7.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
