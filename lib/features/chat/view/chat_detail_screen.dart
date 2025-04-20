// lib/features/chat/screens/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/features/chat/widgets/chat_app_bar.dart';
import 'package:letwork/features/chat/widgets/chat_message_list.dart';
import 'package:letwork/features/chat/widgets/chat_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final String businessId;

  const ChatDetailScreen({super.key, required this.businessId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Future<BusinessModel>? _businessDetails;
  final Color themeColor = const Color(0xFFFF0000);
  bool _isLoading = false;
  int? _userId;
  bool _isInitialized = false;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes:1), (timer) {
      _refreshMessages();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await _fetchUserId();

    setState(() {
      _businessDetails = _fetchBusinessDetails();
      _isInitialized = true;
      _isLoading = false;
    });

    _loadMessages();
  }

  Future<void> _fetchUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      debugPrint("🧪 Mesaj ekranında SharedPreferences'tan gelen userId: $userId");

      if (userId != null) {
        setState(() {
          _userId = userId;
        });
        debugPrint('✅ User ID loaded into state: $_userId');
      } else {
        debugPrint('❌ User ID not found in SharedPreferences');
        _showUserIdError();
      }
    } catch (e) {
      debugPrint('🚨 Error fetching user ID: $e');
    }
  }

  void _showUserIdError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.')),
        );
      }
    });
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

  Future<void> _refreshMessages() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await context.read<ChatCubit>().loadMessages(widget.businessId);
    } catch (e) {
      debugPrint('Mesajlar yenilenirken hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading || !_isInitialized) return;

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('Sending message with user ID: $_userId');

      await context.read<ChatCubit>().sendMessage(
        senderId: _userId.toString(),
        businessId: widget.businessId,
        message: message,
      );

      _messageController.clear();
      await _refreshMessages();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj gönderilirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: ChatAppBar(
        businessDetails: _businessDetails,
        isInitialized: _isInitialized,
        themeColor: themeColor,
        onRefresh: _refreshMessages,
        isRefreshing: _isRefreshing,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isRefreshing)
              LinearProgressIndicator(
                color: themeColor,
                backgroundColor: themeColor.withOpacity(0.2),
              ),
            Expanded(
              child: ChatMessageList(
                userId: _userId,
                scrollController: _scrollController,
                themeColor: themeColor,
                onRetry: _loadMessages,
              ),
            ),
            ChatInputField(
              controller: _messageController,
              isLoading: _isLoading,
              themeColor: themeColor,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}