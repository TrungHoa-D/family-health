import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final int onlineMembers;

  const ChatHeader({super.key, required this.onlineMembers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   const AppAvatar.small(),
                   const SizedBox(width: AppSpacing.sm),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         'chat.group_name'.tr(),
                         style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.w900),
                       ),
                       Row(
                         children: [
                           Container(
                             width: 6,
                             height: 6,
                             decoration: const BoxDecoration(
                               color: AppColors.success,
                               shape: BoxShape.circle,
                             ),
                           ),
                           const SizedBox(width: 4),
                           Text(
                             'chat.online_status'.tr(args: [onlineMembers.toString()]),
                             style: AppStyles.labelSmall.copyWith(
                               color: AppColors.success,
                               fontWeight: FontWeight.bold,
                               fontSize: 10,
                             ),
                           ),
                         ],
                       )
                     ],
                   )
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.emergency, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
