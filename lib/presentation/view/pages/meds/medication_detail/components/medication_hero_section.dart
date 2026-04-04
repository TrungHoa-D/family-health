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
        // Ảnh thuốc tròn 128dp
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: medication.imageUrl != null
                ? Image.network(
                    medication.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
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
        const SizedBox(height: AppSpacing.xs),

        // Mô tả
        if (medication.description != null)
          Text(
            medication.description!,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
