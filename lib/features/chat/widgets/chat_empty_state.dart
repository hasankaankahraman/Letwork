// lib/features/chat/widgets/chat_empty_state.dart
import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  final Color themeColor;

  const ChatEmptyState({
    super.key,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: themeColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Henüz mesaj yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu işletme ile sohbete başlayın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}