class ChatModel {
  final String senderName;
  final String message;
  final String createdAt;
  final String senderId;
  final String businessId;

  ChatModel({
    required this.senderName,
    required this.message,
    required this.createdAt,
    required this.senderId,
    required this.businessId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      senderName: json['sender_name'],
      message: json['message'],
      createdAt: json['created_at'],
      senderId: json['sender_id'].toString(),
      businessId: json['business_id'].toString(),
    );
  }
}
