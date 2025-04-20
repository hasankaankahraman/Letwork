// lib/features/chat/widgets/chat_message_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/features/chat/widgets/message_item.dart';
import 'package:letwork/features/chat/widgets/chat_empty_state.dart';

class ChatMessageList extends StatelessWidget {
  final int? userId;
  final ScrollController scrollController;
  final Color themeColor;
  final VoidCallback onRetry;

  const ChatMessageList({
    super.key,
    required this.userId,
    required this.scrollController,
    required this.themeColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return Center(
            child: CircularProgressIndicator(color: themeColor),
          );
        } else if (state is ChatError) {
          return _buildErrorState(state.message);
        } else if (state is ChatLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return ChatEmptyState(themeColor: themeColor);
          }

          return _buildMessageListView(messages);
        } else {
          return ChatEmptyState(themeColor: themeColor);
        }
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: themeColor.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'Hata: $message',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageListView(List<dynamic> messages) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == userId?.toString();

        return MessageItem(
          message: message,
          isMe: isMe,
          themeColor: themeColor,
        );
      },
    );
  }
}