import 'package:letwork/data/services/chat_service.dart';
import 'package:letwork/data/model/chat_model.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  // Sohbet listesini getir
  Future<List<ChatModel>> getChatList() {
    return _chatService.fetchChatList();
  }

  // Belirli bir işletme ile olan mesajları getir
  Future<List<ChatModel>> getMessages(String businessId) {
    return _chatService.fetchMessages(businessId);
  }


  // Mesaj gönder
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

  // Mesajı okundu olarak işaretle
  Future<Map<String, dynamic>> markMessageAsRead(String messageId) {
    return _chatService.markMessageAsRead(messageId);
  }

  // Tüm mesajları okundu olarak işaretle
  Future<Map<String, dynamic>> markAllMessagesAsRead() {
    return _chatService.markAllMessagesAsRead();
  }

  // Sohbeti sil
  Future<Map<String, dynamic>> deleteChat(String businessId) {
    return _chatService.deleteChat(businessId);
  }
}