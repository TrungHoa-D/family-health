import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/view/pages/chat/chat_cubit.dart';
import 'package:family_health/presentation/view/pages/chat/chat_state.dart';
import 'package:family_health/presentation/view/pages/chat/components/chat_bubble.dart';
import 'package:family_health/presentation/view/pages/chat/components/chat_header.dart';
import 'package:family_health/presentation/view/pages/chat/components/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ChatPage extends BaseCubitPage<ChatCubit, ChatState> {
  const ChatPage({super.key});

  @override
  Widget builder(BuildContext context) {
    return const ChatView();
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ChatHeader(onlineMembers: state.onlineMembers),
          body: Stack(
            children: [
              // Chat List
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 90),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: state.messages[index]);
                },
              ),

              // Input Field Positioned at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ChatInputField(
                  onSend: (text) => context.read<ChatCubit>().sendMessage(text),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
