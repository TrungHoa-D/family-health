import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:flutter/material.dart';

/// Danh sách thông tin thuốc: Liều lượng, Thời gian, Người dùng, Giám sát
class MedicationInfoList extends StatelessWidget {
  const MedicationInfoList({super.key, required this.medication});
  final MedicationModel medication;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'meds.info_schedule_section'.tr(),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Ngày nhập kho
        _InfoRow(
          icon: Icons.calendar_today,
          iconColor: AppColors.secondary,
          label: 'meds.info_created_at'.tr(),
          value: medication.createdAt != null ? DateFormat('dd/MM/yyyy').format(medication.createdAt!) : 'Chưa cập nhật',
        ),
        const SizedBox(height: AppSpacing.md),

        // Ngày hết hạn
        _InfoRow(
          icon: Icons.date_range,
          iconColor: AppColors.error,
          label: 'meds.info_expiry_date'.tr(),
          value: medication.expiryDate != null ? DateFormat('dd/MM/yyyy').format(medication.expiryDate!) : 'Chưa cập nhật',
        ),
        const SizedBox(height: AppSpacing.md),

        // Phân loại
        _InfoRow(
          icon: Icons.category,
          iconColor: const Color(0xFF5C9CE6),
          label: 'meds.category_label'.tr(),
          value: medication.categories.isNotEmpty ? medication.categories.join(', ') : 'Chưa cập nhật',
        ),
        const SizedBox(height: AppSpacing.md),

        // Mô tả
        _InfoRow(
          icon: Icons.description,
          iconColor: const Color(0xFF8D6E63),
          label: 'meds.info_description'.tr(),
          value: medication.description != null && medication.description!.isNotEmpty ? medication.description! : 'Chưa cập nhật',
        ),
        const SizedBox(height: AppSpacing.md),
          
        // Liều lượng tiêu chuẩn
        _InfoRow(
          icon: Icons.medication,
          iconColor: AppColors.primary,
          label: 'meds.info_dosage'.tr(),
          value: medication.dosageStandard.isNotEmpty ? medication.dosageStandard : 'Chưa cập nhật',
        ),
        const SizedBox(height: AppSpacing.md),

        // Số lượng còn lại
        _InfoRow(
          icon: Icons.inventory,
          iconColor: const Color(0xFF66BB6A),
          label: 'meds.info_stock_quantity'.tr(),
          value: medication.stockQuantity != null ? '${medication.stockQuantity} ${medication.unit ?? ''}'.trim() : 'Chưa cập nhật',
        ),
      ],
    );
  }
}

/// Một hàng thông tin: icon tròn + label + value
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


