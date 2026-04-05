import 'package:cached_network_image/cached_network_image.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.size = 40,
    this.onTap,
  });

  const AppAvatar.small({
    super.key,
    this.imageUrl,
    this.name = '',
    this.onTap,
  }) : size = 32;

  const AppAvatar.medium({
    super.key,
    this.imageUrl,
    this.name = '',
    this.onTap,
  }) : size = 48;

  const AppAvatar.large({
    super.key,
    this.imageUrl,
    this.name = '',
    this.onTap,
  }) : size = 80;

  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: _getPlaceholderColor(name),
      child: Center(
        child: Text(
          initials,
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Color _getPlaceholderColor(String name) {
    if (name.isEmpty) return AppColors.primary;
    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
      const Color(0xFF26A69A),
    ];
    return colors[name.length % colors.length];
  }
}
