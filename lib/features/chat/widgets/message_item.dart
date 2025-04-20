// lib/features/chat/widgets/message_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final Color themeColor;

  const MessageItem({
    super.key,
    required this.message,
    required this.isMe,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final senderName = message.senderName ?? 'Bilinmeyen';

    DateTime messageTime;
    try {
      if (message.createdAt is DateTime) {
        messageTime = message.createdAt;
      } else {
        messageTime = DateTime.parse(message.createdAt.toString());
      }
    } catch (e) {
      messageTime = DateTime.now();
      debugPrint('Tarih dönüştürme hatası: $e');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Gönderen ismi
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
            child: Text(
              senderName,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? themeColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isMe ? themeColor : themeColor.withOpacity(0.3),
                      width: isMe ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(messageTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildReadStatus(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadStatus() {
    final isRead = message.isRead ?? false;

    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 14,
      color: isRead ? themeColor : Colors.grey[400],
    );
  }
}