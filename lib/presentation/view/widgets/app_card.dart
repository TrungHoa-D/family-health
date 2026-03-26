import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/view/widgets/safe_click_widget.dart';
import 'package:flutter/material.dart';

/// Family Health — Card Component
///
/// Theo Style Guide:
/// - Border radius: 16px
/// - Nền: Trắng (#FFFFFF)
/// - Shadow: 0 2px 8px rgba(0,0,0,0.06)
/// - Không viền mặc định
class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1,
    this.enableShadow = true,
    this.borderRadius,
    this.onPressed,
  }) : super(key: key);

  final Color? backgroundColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;
  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool enableShadow;
  final double? borderRadius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusCard;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          if (enableShadow)
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
        border: hasBorder
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.hardEdge,
        child: SafeClickWidget(
          onPressed: onPressed,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
