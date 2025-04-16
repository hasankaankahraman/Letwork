class ChatModel {
  final String id;
  final String senderName;
  final String message;
  final String createdAt;
  final String senderId;
  final String businessId;
  final bool isRead;
  final String? businessImage;

  ChatModel({
    required this.id,
    required this.senderName,
    required this.message,
    required this.createdAt,
    required this.senderId,
    required this.businessId,
    required this.isRead,
    this.businessImage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      senderName: json['sender_name'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == '1' || json['is_read'] == true,
      businessImage: json['business_image'],
    );
  }
}