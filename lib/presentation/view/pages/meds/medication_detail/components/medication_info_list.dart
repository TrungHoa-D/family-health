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

        // Liều lượng
        _InfoRow(
          icon: Icons.medication,
          iconColor: AppColors.primary,
          label: 'meds.info_dosage'.tr(),
          value: medication.dosage ?? '',
        ),
        const SizedBox(height: AppSpacing.md),

        // Thời gian
        _InfoRow(
          icon: Icons.schedule,
          iconColor: AppColors.secondary,
          label: 'meds.info_timing'.tr(),
          value: medication.timingDescription ?? '',
        ),
        const SizedBox(height: AppSpacing.md),

        // Người dùng
        _InfoRow(
          icon: Icons.person,
          iconColor: const Color(0xFFA33200),
          label: 'meds.info_user'.tr(),
          value: medication.targetUserName ?? medication.memberName,
        ),
        const SizedBox(height: AppSpacing.md),

        // Người giám sát
        _SupervisorRow(
          supervisorNames: medication.supervisorNames,
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

/// Hàng giám sát — hiển thị avatar chồng nhau
class _SupervisorRow extends StatelessWidget {
  const _SupervisorRow({required this.supervisorNames});
  final List<String> supervisorNames;

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
            child: const Center(
              child: Icon(Icons.group, color: Color(0xFF5C9CE6), size: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Supervisor info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'meds.info_supervisor'.tr().toUpperCase(),
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildAvatarStack(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    if (supervisorNames.isEmpty) {
      return Text(
        '—',
        style: AppStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    final displayCount =
        supervisorNames.length > 2 ? 2 : supervisorNames.length;
    final remaining = supervisorNames.length - displayCount;

    return Row(
      children: [
        // Stacked avatar circles
        SizedBox(
          width: (displayCount * 24.0) + (remaining > 0 ? 32 : 0),
          height: 32,
          child: Stack(
            children: [
              for (int i = 0; i < displayCount; i++)
                Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: _getAvatarColor(i),
                      child: Text(
                        supervisorNames[i][0],
                        style: AppStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              if (remaining > 0)
                Positioned(
                  left: displayCount * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '+$remaining',
                        style: AppStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(int index) {
    const colors = [
      Color(0xFF78909C),
      Color(0xFF8D6E63),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
    ];
    return colors[index % colors.length];
  }
}
