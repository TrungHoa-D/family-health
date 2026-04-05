import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.userName,
    this.userPhotoUrl,
    this.onNotificationTap,
  });
  final String? userName;
  final String? userPhotoUrl;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar.medium(
            imageUrl: userPhotoUrl,
            name: userName ?? 'U',
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'home.greeting_with_name'
                  .tr(args: [userName ?? 'home.user'.tr()]),
              style: AppStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }
}
