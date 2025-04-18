import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/features/chat/view/chat_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:letwork/features/main_wrapper/main_wrapper_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final Color themeColor = const Color(0xFFFF0000);

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    context.read<ChatCubit>().loadChatList();
  }

  String _formatLastMessageTime(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;

    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      try {
        dateTime = DateTime.parse(timestamp);
      } catch (_) {
        return '';
      }
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'tr_TR').format(dateTime);
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Mesajlar',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: themeColor),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: themeColor),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                // Tümünü okundu olarak işaretle
              } else if (value == 'settings') {
                // Mesaj ayarları
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_chat_read, size: 18, color: themeColor),
                    const SizedBox(width: 8),
                    const Text('Tümünü Okundu İşaretle'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18, color: themeColor),
                    const SizedBox(width: 8),
                    const Text('Mesaj Ayarları'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: () async {
          _loadChats();
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return Center(
                child: CircularProgressIndicator(color: themeColor),
              );
            } else if (state is ChatError) {
              return _buildErrorView(state.message);
            } else if (state is ChatLoaded && state.messages.isNotEmpty) {
              return _buildChatList(state.messages);
            } else {
              return _buildEmptyState();
            }
          },
        ),
      ),
    );
  }

  Widget _buildChatList(List<dynamic> chats) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final bool hasUnreadMessages = chat.unreadCount != null && chat.unreadCount > 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(businessId: chat.businessId),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: themeColor.withOpacity(0.1),
                  backgroundImage: NetworkImage(chat.profileImageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              chat.senderName ?? 'İşletme',
                              style: TextStyle(
                                fontWeight: hasUnreadMessages
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatLastMessageTime(chat.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnreadMessages
                                  ? themeColor
                                  : Colors.grey[500],
                              fontWeight: hasUnreadMessages
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.message ?? '',
                              style: TextStyle(
                                color: hasUnreadMessages
                                    ? Colors.black87
                                    : Colors.grey[600],
                                fontWeight: hasUnreadMessages
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnreadMessages) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: themeColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz bir mesajınız yok',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'İşletmelerle iletişime geçerek mesajlaşmaya başlayabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.explore, color: Colors.white),
            label: const Text('İşletmelere Göz At'),
            onPressed: () {
              // MainWrapperScreen'e git ve home tab'ını seç
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainWrapperScreen(),
                ),
                    (route) => false, // Tüm route stack'i temizle
              );

              // Eğer MainWrapperScreen'de bir tab controller varsa,
              // o tabı seçmek için gerekli parametreyi iletebilirsiniz
              // Örnek: MainWrapperScreen(initialTabIndex: 0)
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70, color: themeColor.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            onPressed: _loadChats,
          ),
        ],
      ),
    );
  }
}