import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class SimplifiedMedicationListItem extends StatelessWidget {
  const SimplifiedMedicationListItem({
    super.key,
    required this.schedule,
    this.onTap,
  });

  final PatientSchedule schedule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isTaken = false; // logic will be linked later with logs

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isTaken ? AppColors.success.withValues(alpha: 0.3) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.medication, color: AppColors.primary, size: 36),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.medName,
                    style: AppStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    'Giờ uống: ${schedule.timing['anchor_event']}',
                    style: AppStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            if (isTaken)
              const Icon(Icons.check_circle, color: AppColors.success, size: 40)
            else
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 32),
          ],
        ),
      ),
    );
  }
}
