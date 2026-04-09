import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

import 'simplified_medication_list_item.dart';

class SimplifiedHomeView extends StatelessWidget {
  const SimplifiedHomeView({
    super.key,
    required this.userName,
    required this.progress,
    required this.meds,
    required this.onTakenMedication,
    required this.onEmergencyCall,
    required this.onExitSimplifiedMode,
    required this.onChatTap,
    required this.onAiChatTap,
  });

  final String? userName;
  final double progress; // 0.0 to 1.0
  final List<PatientSchedule> meds;
  final VoidCallback onTakenMedication;
  final VoidCallback onEmergencyCall;
  final VoidCallback onExitSimplifiedMode;
  final VoidCallback onChatTap;
  final VoidCallback onAiChatTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'simplified.welcome'.tr(args: [userName ?? 'user.user'.tr()]),
                          style: AppStyles.titleLarge.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'simplified.how_are_you'.tr(),
                          style: AppStyles.bodyLarge.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 32, color: AppColors.textSecondary),
                    onPressed: onExitSimplifiedMode,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Progress Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'simplified.med_progress'.tr(),
                      style: AppStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 20,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.success),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'simplified.completion'.tr(args: [(progress * 100).toInt().toString()]),
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Medication List
              const SizedBox(height: AppSpacing.xl),
              Text(
                'simplified.today_schedule'.tr(),
                style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.md),
              meds.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl),
                        child: Text(
                          'simplified.no_meds'.tr(),
                          style: AppStyles.bodyLarge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meds.length,
                      itemBuilder: (context, index) {
                        return SimplifiedMedicationListItem(
                          schedule: meds[index],
                          onTap: onTakenMedication,
                        );
                      },
                    ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              _SmallActionButton(
                title: 'simplified.chat_btn'.tr(),
                icon: Icons.chat,
                color: AppColors.secondary,
                onTap: onChatTap,
              ),
              const SizedBox(height: AppSpacing.md),
              _SmallActionButton(
                title: 'simplified.ai_chat_btn'.tr(),
                icon: Icons.psychology,
                color: AppColors.primary,
                onTap: onAiChatTap,
              ),
              const SizedBox(height: AppSpacing.md),
              _SmallActionButton(
                title: 'simplified.emergency_btn'.tr(),
                icon: Icons.emergency,
                color: Colors.redAccent,
                onTap: onEmergencyCall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Huge "Taken Medication" Button
              _BigActionButton(
                title: 'simplified.taken_btn'.tr(),
                subtitle: 'simplified.taken_subtitle'.tr(),
                icon: Icons.check_circle,
                color: AppColors.primary,
                onTap: onTakenMedication,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
