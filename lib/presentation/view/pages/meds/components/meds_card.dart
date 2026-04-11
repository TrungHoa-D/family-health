import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import '../meds_cubit.dart';

class MedsCard extends StatelessWidget {
  const MedsCard({super.key, required this.medication, this.onTap});
  final MedicationModel medication;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onPressed: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: medication.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    child: Image.network(
                      medication.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.medication,
                            color: Colors.white, size: 32),
                      ),
                    ),
                  )
                : const Center(
                    child:
                        Icon(Icons.medication, color: Colors.white, size: 32),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medication.name,
                        style: AppStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusTag(),
                  ],
                ),
                if (medication.targetUserName != null)
                  Text(
                    'meds.member_label'.tr(args: [medication.targetUserName!]),
                    style: AppStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (medication.scheduleDescription?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                medication.scheduleDescription!,
                                style: AppStyles.labelSmall
                                    .copyWith(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          // Thông tin kho và hạn sử dụng
                          Text(
                            'Kho: ${medication.stockQuantity ?? 0} ${medication.unit ?? ''}'.trim(),
                            style: AppStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HSD: ${medication.expiryDate != null ? DateFormat('dd/MM/yyyy').format(medication.expiryDate!) : '--'}',
                            style: AppStyles.labelSmall.copyWith(
                              color: isExpired ? AppColors.error : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'meds.detail_link'.tr(),
                            style: AppStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get isExpired {
    if (medication.expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(medication.expiryDate!.year, medication.expiryDate!.month, medication.expiryDate!.day);
    return expiry.isBefore(today);
  }

  Widget _buildStatusTag() {
    if (isExpired) {
      return _Tag(
        label: 'HẾT HẠN',
        color: AppColors.error.withValues(alpha: 0.1),
        textColor: AppColors.error,
      );
    }
    return _Tag(
      label: medication.tag,
      color: medication.tagColor,
      textColor: medication.textColor,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
