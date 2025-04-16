import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String businessId;

  const ChatDetailScreen({super.key, required this.businessId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Future<BusinessModel> _businessDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _businessDetails = _fetchBusinessDetails();
    _loadMessages();
  }

  Future<BusinessModel> _fetchBusinessDetails() async {
    try {
      final businessService = BusinessService();
      final businessDetail = await businessService.fetchBusinessDetail(widget.businessId);

      return BusinessModel(
        id: businessDetail.id,
        userId: businessDetail.userId,
        name: businessDetail.name,
        description: businessDetail.description,
        address: businessDetail.address,
        category: businessDetail.category,
        subCategory: businessDetail.subCategory,
        profileImage: businessDetail.profileImage,
        ownerName: businessDetail.ownerName,
        latitude: businessDetail.latitude,
        longitude: businessDetail.longitude,
        isFavorite: businessDetail.isFavorite,
      );
    } catch (e) {
      debugPrint('İşletme detayları alınırken hata: $e');
      rethrow;
    }
  }

  void _loadMessages() {
    context.read<ChatCubit>().loadMessages(widget.businessId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await context.read<ChatCubit>().sendMessage(
        senderId: 'userId',  // Kullanıcı ID'nizi buraya ekleyin
        businessId: widget.businessId,
        message: message,
      );

      _messageController.clear();

      // Mesaj listesini en alta kaydır
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderilirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return DateFormat('HH:mm').format(DateTime.now());

    DateTime dateTime;

    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      try {
        dateTime = DateTime.parse(timestamp);
      } catch (_) {
        return DateFormat('HH:mm').format(DateTime.now());
      }
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateFormat('HH:mm').format(DateTime.now());
    }

    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildChatMessages(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: FutureBuilder<BusinessModel>(
        future: _businessDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Hata oluştu',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            );
          } else if (snapshot.hasData) {
            final business = snapshot.data!;
            return _buildBusinessHeader(business);
          } else {
            return const Text(
              'İşletme Bulunamadı',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            );
          }
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onSelected: (value) {
            switch (value) {
              case 'profile':
              // İşletme profilini göster
                break;
              case 'block':
              // İşletmeyi engelle
                break;
              case 'report':
              // İşletmeyi şikayet et
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.store, size: 18),
                  SizedBox(width: 8),
                  Text('İşletme Profili'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 18),
                  SizedBox(width: 8),
                  Text('İşletmeyi Engelle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 18),
                  SizedBox(width: 8),
                  Text('Şikayet Et'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessHeader(BusinessModel business) {
    return Row(
      children: [
        Hero(
          tag: 'business-${business.id}',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                business.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.store, color: Colors.grey),
                ),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.name ?? 'İşletme',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Çevrimiçi', // Veya işletme durumuna göre değişebilir
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessages() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${state.message}',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMessages,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        } else if (state is ChatLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return _buildEmptyState();
          }

          return _buildChatList(messages);
        } else {
          return _buildEmptyState();
        }
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
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bir mesaj yok',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İşletmeye ilk mesajı gönder',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.message_rounded),
            label: const Text('Mesaj Yaz'),
            onPressed: () {
              // TextField'a odaklan
              FocusScope.of(context).requestFocus(
                  FocusNode()
              );
              // 300ms sonra TextField'a odaklan
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _messageController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _messageController.text.length)
                  );
                  FocusScope.of(context).unfocus();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<dynamic> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == 'userId'; // Kullanıcı ID'nizi kontrol edin

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _buildChatBubble(message, isMe),
        );
      },
    );
  }

  Widget _buildChatBubble(dynamic message, bool isMe) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          FutureBuilder<BusinessModel>(
            future: _businessDetails,
            builder: (context, snapshot) {
              String imageUrl = "https://letwork.hasankaan.com/assets/default_profile.png";
              if (snapshot.hasData) {
                imageUrl = snapshot.data!.profileImageUrl;
              }

              return CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(imageUrl),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                Text(
                  message.message ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isMe) ...[
                      Icon(
                        message.isRead ?? false
                            ? Icons.done_all
                            : Icons.done,
                        size: 14,
                        color: isMe ? Colors.white70 : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _formatMessageTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
              onPressed: () {
                // Dosya ekleme menüsünü aç
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildAttachmentMenu(),
                );
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Mesajınızı yazın...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                      onPressed: () {
                        // Emoji picker'ı aç
                      },
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    final List<Map<String, dynamic>> attachmentOptions = [
      {'icon': Icons.photo_library, 'title': 'Galeri', 'color': Colors.purple},
      {'icon': Icons.camera_alt, 'title': 'Kamera', 'color': Colors.blue},
      {'icon': Icons.location_on, 'title': 'Konum', 'color': Colors.green},
      {'icon': Icons.insert_drive_file, 'title': 'Dosya', 'color': Colors.orange},
    ];

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: attachmentOptions.length,
        itemBuilder: (context, index) {
          final option = attachmentOptions[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // Burada ilgili eklenti için işlemi gerçekleştir
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: option['color'],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option['icon'],
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}