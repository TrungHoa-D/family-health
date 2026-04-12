import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/view/widgets/image_preview_popup.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  final void Function(String text, List<File> images) onSend;
  final bool isSending;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  bool get _canSend => _hasText || _selectedImages.isNotEmpty;

  void _handleSend() {
    if (!_canSend || widget.isSending) return;

    widget.onSend(_controller.text, List<File>.from(_selectedImages));
    _controller.clear();
    setState(() {
      _selectedImages.clear();
      _hasText = false;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedFiles.isEmpty) return;

      final totalCount = _selectedImages.length + pickedFiles.length;

      if (totalCount > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tối đa 5 ảnh mỗi tin nhắn'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
        // Chỉ lấy đủ 5 ảnh
        final remaining = 5 - _selectedImages.length;
        if (remaining <= 0) return;
        setState(() {
          _selectedImages.addAll(
            pickedFiles.take(remaining).map((xf) => File(xf.path)),
          );
        });
      } else {
        setState(() {
          _selectedImages.addAll(
            pickedFiles.map((xf) => File(xf.path)),
          );
        });
      }
    } catch (_) {
      // Silently handle picker cancellation or errors
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview strip
          if (_selectedImages.isNotEmpty) _buildImagePreview(),

          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'chat.input_placeholder'.tr(),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),

              // Image picker button (right side)
              IconButton(
                icon: Icon(
                  Icons.image_outlined,
                  color: _selectedImages.length >= 5
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : AppColors.textSecondary,
                ),
                onPressed:
                    _selectedImages.length >= 5 ? null : _pickImages,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),

              // Send button — only visible when can send
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: _canSend
                    ? widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : IconButton(
                            key: const ValueKey('send_btn'),
                            icon: const Icon(
                              Icons.send_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: _handleSend,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          )
                    : const SizedBox(
                        key: ValueKey('empty_send'),
                        width: 8,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(
        left: 4,
        right: 4,
        top: 4,
        bottom: 4,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildPreviewItem(index);
        },
      ),
    );
  }

  Widget _buildPreviewItem(int index) {
    final file = _selectedImages[index];
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image thumbnail
          GestureDetector(
            onTap: () => ImagePreviewPopup.showLocalFile(context, file),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Remove button (X)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
