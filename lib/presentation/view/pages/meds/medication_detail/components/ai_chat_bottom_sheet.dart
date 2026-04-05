import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../ai_chat_cubit.dart';

class AiChatBottomSheet extends StatefulWidget {
  const AiChatBottomSheet({super.key, required this.medicationName});
  final String medicationName;

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AIChatCubit>().init(widget.medicationName);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIChatCubit, AIChatState>(
      listener: (context, state) {
        if (!state.isTyping) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      },
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(bottom: BorderSide(color: AppColors.surface)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trợ lý AI - ${widget.medicationName}', style: AppStyles.titleMedium),
                          Text('Hỗ trợ thông tin y khoa cơ bản', style: AppStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Chat Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const TypingIndicator();
                    }
                    final message = state.messages[index];
                    return ChatBubble(message: message);
                  },
                ),
              ),

              // Input
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Hỏi AI về thuốc này...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                        onSubmitted: (value) => _sendMessage(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => _sendMessage(context),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: AppColors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(BuildContext context) {
    if (_controller.text.trim().isNotEmpty) {
      context.read<AIChatCubit>().sendMessage(_controller.text);
      _controller.clear();
    }
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomLeft: message.isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: AppStyles.bodyMedium.copyWith(
              color: message.isUser ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12).copyWith(bottomLeft: Radius.zero),
        ),
        child: const SizedBox(
            width: 40,
            child: LinearProgressIndicator(minHeight: 2, backgroundColor: AppColors.background, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
      ),
    );
  }
}

// Custom Markdown Config to handle styles simply
class MarkdownStyleConfig {
  MarkdownStyleConfig({required this.p});
  final TextStyle p;
}
