import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

class DashboardMembersSection extends StatelessWidget {
  const DashboardMembersSection({
    super.key,
    required this.members,
    this.onViewAll,
  });
  final List<DashboardMemberModel> members;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👨‍👩‍👧', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'home.members'.tr(),
                    style: AppStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'home.view_all'.tr(),
                  style:
                      AppStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: members.length + 1,
            itemBuilder: (context, index) {
              if (index == members.length) {
                return _buildAddButton();
              }
              return _MemberItem(member: members[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 100,
      margin:
          const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'home.add'.tr(),
            style:
                AppStyles.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class DashboardMemberModel {
  DashboardMemberModel({
    required this.name,
    this.photoUrl,
    required this.progress,
    required this.statusColor,
  });
  final String name;
  final String? photoUrl;
  final String progress; // e.g. "4/6"
  final Color statusColor;
}

class _MemberItem extends StatelessWidget {
  const _MemberItem({required this.member});
  final DashboardMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin:
          const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              AppAvatar.large(imageUrl: member.photoUrl),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: member.statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            member.name,
            style: AppStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            member.progress,
            style: AppStyles.labelSmall.copyWith(
              color: member.statusColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
