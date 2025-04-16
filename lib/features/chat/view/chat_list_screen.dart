import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/features/chat/view/chat_detail_screen.dart';
import 'package:letwork/data/model/chat_model.dart';
import 'package:intl/intl.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/view/home_screen.dart';
import 'package:letwork/features/home/repository/home_repository.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
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
      // Bugün ise saati göster
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Dün ise
      return 'Dün';
    } else if (difference.inDays < 7) {
      // Son bir hafta içindeyse günü göster
      return DateFormat('EEEE', 'tr_TR').format(dateTime);
    } else {
      // Daha eskiyse tarihi göster
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
        title: const Text(
          'Mesajlar',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              // Menu aksiyonları
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_chat_read, size: 18),
                    SizedBox(width: 8),
                    Text('Tümünü Okundu İşaretle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Mesaj Ayarları'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadChats();
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(
                child: CircularProgressIndicator(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni mesaj oluşturma ekranına git
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList(List<dynamic> chats) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: chats.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 80,
        color: Colors.grey[200],
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'business-${chat.businessId}',
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: chat.profileImage != null
                              ? Image.network(
                            chat.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.store, color: Colors.grey),
                            ),
                          )
                              : const Center(
                            child: Icon(Icons.store, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    if (chat.isOnline == true)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
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
                                  ? Theme.of(context).primaryColor
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
                                color: Theme.of(context).primaryColor,
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bir mesajınız yok',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İşletmelerle iletişime geçerek mesajlaşmaya başlayabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.explore),
            label: const Text('İşletmelere Göz At'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => HomeCubit(HomeRepository()),
                    child: const HomeScreen(),
                  ),
                ),
              );
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
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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