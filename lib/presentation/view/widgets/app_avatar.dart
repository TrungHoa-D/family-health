import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:flutter/material.dart';

/// Family Health — Avatar Component
///
/// Theo Style Guide:
/// - Hình tròn (Circle)
/// - Border 2px màu Primary Light
/// - Sizes: small (24dp), medium (40dp), large (48dp), xlarge (64dp), xxlarge (72dp)
/// - Fallback: icon person trên nền surface
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    Key? key,
    this.imageUrl,
    this.size = AppSpacing.avatarLarge,
    this.borderWidth = 2,
    this.borderColor = AppColors.primaryLight,
    this.fallbackIcon = Icons.person,
    this.onTap,
  }) : super(key: key);

  /// Small avatar (24dp) — inline in chat bubbles
  const AppAvatar.small({
    Key? key,
    this.imageUrl,
    this.borderWidth = 1,
    this.borderColor = AppColors.primaryLight,
    this.fallbackIcon = Icons.person,
    this.onTap,
  })  : size = AppSpacing.avatarSmall,
        super(key: key);

  /// Medium avatar (40dp) — list items
  const AppAvatar.medium({
    Key? key,
    this.imageUrl,
    this.borderWidth = 2,
    this.borderColor = AppColors.primaryLight,
    this.fallbackIcon = Icons.person,
    this.onTap,
  })  : size = AppSpacing.avatarMedium,
        super(key: key);

  /// Large avatar (48dp) — member cards
  const AppAvatar.large({
    Key? key,
    this.imageUrl,
    this.borderWidth = 2,
    this.borderColor = AppColors.primaryLight,
    this.fallbackIcon = Icons.person,
    this.onTap,
  })  : size = AppSpacing.avatarLarge,
        super(key: key);

  /// Extra large avatar (64dp) — Settings profile
  const AppAvatar.xlarge({
    Key? key,
    this.imageUrl,
    this.borderWidth = 2,
    this.borderColor = AppColors.primaryLight,
    this.fallbackIcon = Icons.person,
    this.onTap,
  })  : size = AppSpacing.avatarXLarge,
        super(key: key);

  /// XXL avatar (72dp) — Simplified Mode greeting
  const AppAvatar.xxlarge({
    Key? key,
    this.imageUrl,
    this.borderWidth = 3,
    this.borderColor = AppColors.secondary,
    this.fallbackIcon = Icons.person,
    this.onTap,
  })  : size = AppSpacing.avatarXXLarge,
        super(key: key);

  /// URL of avatar image (network)
  final String? imageUrl;

  /// Size in dp (diameter)
  final double size;

  /// Border width
  final double borderWidth;

  /// Border color
  final Color borderColor;

  /// Icon when no image available
  final IconData fallbackIcon;

  /// Tap handler
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surface,
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}
