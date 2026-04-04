import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/chat/chat_state.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    if (message.senderType == MessageSenderType.systemAi) {
      return _SystemAiBubble(message: message);
    }
    if (message.senderType == MessageSenderType.me) {
      return _MyBubble(message: message);
    }
    return _OtherMemberBubble(message: message);
  }
}

class _SystemAiBubble extends StatelessWidget {
  const _SystemAiBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final parts = message.content.split('\n');
    final title = parts.isNotEmpty ? parts[0] : '';
    final sub = parts.length > 1 ? parts.sublist(1).join('\n') : '';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.titleSmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (sub.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: AppStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'chat.details'.tr().toUpperCase(),
              style: AppStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyBubble extends StatelessWidget {
  const _MyBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 48,
        right: AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16)
                  .copyWith(bottomRight: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: AppStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('hh:mm a').format(message.time),
                style: AppStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherMemberBubble extends StatelessWidget {
  const _OtherMemberBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: 48,
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                message.avatarUrl ?? 'U',
                style: AppStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    message.senderName?.toUpperCase() ?? 'MEMBER',
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16)
                        .copyWith(bottomLeft: const Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: AppStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    DateFormat('hh:mm a').format(message.time),
                    style: AppStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, fontSize: 10),
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
