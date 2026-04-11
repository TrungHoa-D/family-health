import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

import '../meds_cubit.dart';
import 'medication_search_delegate.dart';

class MedsHeader extends StatelessWidget {
  const MedsHeader({
    super.key,
    this.onAddMedication,
    this.medications = const [],
  });

  final VoidCallback? onAddMedication;
  final List<MedicationModel> medications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'meds.title'.tr(),
            style: AppStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            children: [
              _ActionButton(
                icon: Icons.search,
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: MedicationSearchDelegate(medications),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _AddButton(onTap: onAddMedication),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: Colors.black87),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }
}
