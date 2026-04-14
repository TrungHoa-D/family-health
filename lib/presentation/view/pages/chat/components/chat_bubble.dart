import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/chat/chat_cubit.dart';
import 'package:family_health/presentation/view/pages/chat/components/chat_image_grid.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final isOlderThan1Day = now.difference(timestamp).inDays >= 1 || now.day != timestamp.day;
  if (isOlderThan1Day) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }
  return DateFormat('hh:mm a').format(timestamp);
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    if (message.senderId == 'system_ai') {
      return _SystemAiBubble(message: message);
    }
    if (isMe) {
      return _MyBubble(message: message);
    }
    return _OtherMemberBubble(message: message);
  }
}

class _SystemAiBubble extends StatelessWidget {
  const _SystemAiBubble({required this.message});
  final ChatMessage message;

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
  final ChatMessage message;

  bool get _hasImages => message.imageUrls.isNotEmpty;
  bool get _hasText => message.content.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Padding(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Images
                if (_hasImages)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ChatImageGrid(imageUrls: message.imageUrls),
                    ),
                  ),

                // Text content
                if (_hasText)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 8,
                      top: _hasImages ? 4 : 8,
                    ),
                    child: Text(
                      message.content,
                      style: AppStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTimestamp(message.timestamp),
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
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasText)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                title: Text('Chỉnh sửa tin nhắn'.tr()),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditDialog(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Xóa tin nhắn'.tr(), style: const TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<ChatCubit>().deleteMessage(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Chỉnh sửa tin nhắn'.tr()),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung'.tr(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy'.tr()),
          ),
          FilledButton(
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                context.read<ChatCubit>().editMessage(message.id, newContent);
                Navigator.pop(dialogContext);
              }
            },
            child: Text('Lưu'.tr()),
          ),
        ],
      ),
    );
  }
}

class _OtherMemberBubble extends StatelessWidget {
  const _OtherMemberBubble({required this.message});
  final ChatMessage message;

  bool get _hasImages => message.imageUrls.isNotEmpty;
  bool get _hasText => message.content.trim().isNotEmpty;

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
            margin: const EdgeInsets.only(bottom: 16),
            child: AppAvatar.small(imageUrl: message.senderAvatarUrl),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    message.senderName.toUpperCase(),
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images
                      if (_hasImages)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ChatImageGrid(imageUrls: message.imageUrls),
                          ),
                        ),

                      // Text content
                      if (_hasText)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 8,
                            top: _hasImages ? 4 : 8,
                          ),
                          child: Text(
                            message.content,
                            style: AppStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _formatTimestamp(message.timestamp),
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
