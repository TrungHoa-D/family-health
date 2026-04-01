import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class MedsHeader extends StatelessWidget {
  const MedsHeader({super.key});

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
              _ActionButton(icon: Icons.search, onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _ActionButton(icon: Icons.filter_list, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

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
