import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Color themeColor = const Color(0xFFFF0000);
  bool _isLoading = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _businessDetails = _fetchBusinessDetails();
    _loadMessages();
  }

  Future<void> _fetchUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getInt('userId');
      });
      debugPrint('User ID loaded: $_userId');
    } catch (e) {
      debugPrint('Error fetching user ID: $e');
    }
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

    // Check if user ID is available
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<ChatCubit>().sendMessage(
        senderId: _userId.toString(), // Use dynamic user ID instead of hardcoded '1'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
      scrolledUnderElevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: themeColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: themeColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: FutureBuilder<BusinessModel>(
        future: _businessDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeColor,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Hata oluştu',
              style: TextStyle(color: themeColor, fontSize: 14),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: themeColor,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: themeColor),
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
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.store, size: 18, color: themeColor),
                  const SizedBox(width: 8),
                  const Text('İşletme Profili'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 18, color: themeColor),
                  const SizedBox(width: 8),
                  const Text('İşletmeyi Engelle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 18, color: themeColor),
                  const SizedBox(width: 8),
                  const Text('Şikayet Et'),
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
              border: Border.all(color: themeColor, width: 2),
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
              borderRadius: BorderRadius.circular(19),
              child: Image.network(
                business.profileImage.isNotEmpty
                    ? "https://letwork.hasankaan.com/${business.profileImage}"
                    : "https://letwork.hasankaan.com/assets/default_profile.png",
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
                business.name,
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
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Çevrimiçi',
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
          return Center(
            child: CircularProgressIndicator(color: themeColor),
          );
        } else if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: themeColor.withOpacity(0.7)),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${state.message}',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMessages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                  ),
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

  Widget _buildChatList(List<dynamic> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == _userId?.toString(); // Updated to use dynamic user ID

        DateTime messageTime;
        try {
          messageTime = DateTime.parse(message.createdAt);
        } catch (e) {
          messageTime = DateTime.now();
          debugPrint('Tarih dönüştürme hatası: $e');
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                            DateFormat('HH:mm').format(messageTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildReadStatus(message),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadStatus(dynamic message) {
    final isRead = message.isRead ?? false;

    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 14,
      color: isRead ? themeColor : Colors.grey[400],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: themeColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: themeColor.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
}