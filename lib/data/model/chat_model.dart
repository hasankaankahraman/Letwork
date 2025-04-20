import 'package:intl/intl.dart';

class ChatModel {
  final String id;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final String senderId;
  final String businessId;
  final String businessName;
  final String? profileImage;
  final bool isRead;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastTime;
  final String? lastSenderName; // <-- yeni alan

  ChatModel({
    this.id = '',
    this.senderName = '',
    this.message = '',
    required this.createdAt,
    this.senderId = '',
    required this.businessId,
    this.businessName = '',
    this.profileImage,
    this.isRead = false,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastTime,
    this.lastSenderName, // <-- constructor'a eklendi
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final bool isUserChat = json.containsKey('business_name');

    return ChatModel(
      id: json['id']?.toString() ?? '',
      senderName: json['sender_name'] ?? json['business_name'] ?? '',
      businessName: json['business_name'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['last_time'] ?? '') ?? DateTime.now(),
      senderId: json['sender_id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == '1' || json['is_read'] == true,
      profileImage: isUserChat ? json['profile_image'] : json['business_image'],
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'],
      lastTime: json['last_time'] != null ? DateTime.tryParse(json['last_time']) : null,
      lastSenderName: json['last_sender_name'], // <-- burası eklendi
    );
  }

  String get profileImageUrl {
    if (profileImage == null || profileImage!.isEmpty) {
      return "https://letwork.hasankaan.com/assets/default_profile.png";
    }

    if (profileImage!.startsWith('http')) {
      return profileImage!;
    }

    return "https://letwork.hasankaan.com/$profileImage";
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(createdAt);
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'tr_TR').format(createdAt);
    } else {
      return DateFormat('dd.MM.yyyy').format(createdAt);
    }
  }

  String get displayMessage => message.isNotEmpty ? message : lastMessage ?? '';
  DateTime get displayTime => lastTime ?? createdAt;

  String get lastMessageTime {
    final timeToFormat = lastTime ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(timeToFormat);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timeToFormat);
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'tr_TR').format(timeToFormat);
    } else {
      return DateFormat('dd.MM.yyyy').format(timeToFormat);
    }
  }
}
