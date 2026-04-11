import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:flutter/material.dart';

/// Hero section: Ảnh thuốc tròn + Tên thuốc lớn + Mô tả
class MedicationHeroSection extends StatelessWidget {
  const MedicationHeroSection({super.key, required this.medication});
  final MedicationModel medication;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ảnh thuốc hình chữ nhật
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: medication.imageUrl != null
                  ? Image.network(
                      medication.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Tên thuốc lớn
        Text(
          medication.name,
          style: AppStyles.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.medication,
          color: AppColors.primary,
          size: 56,
        ),
      ),
    );
  }
}
