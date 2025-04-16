import 'package:letwork/data/services/chat_service.dart';
import 'package:letwork/data/model/chat_model.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  Future<List<ChatModel>> getMessages(String businessId) {
    return _chatService.fetchMessages(businessId);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String businessId,
    required String message,
  }) {
    return _chatService.sendMessage(
      senderId: senderId,
      businessId: businessId,
      message: message,
    );
  }
}
