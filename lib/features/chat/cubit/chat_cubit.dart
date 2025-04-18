import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letwork/features/chat/repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  // 🔧 Sohbet listesini kullanıcı ID'siyle yükle
  Future<void> loadChatList() async {
    try {
      emit(ChatLoading());

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        emit(ChatError(message: "Kullanıcı ID'si bulunamadı"));
        return;
      }

      // 💬 Debug: doğru userId geldi mi görelim
      print("📥 ChatCubit -> userId: $userId");

      final chats = await _chatRepository.getChatList(userId: userId);
      emit(ChatLoaded(messages: chats));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // Belirli bir işletme için mesajları yükle
  Future<void> loadMessages(String businessId) async {
    try {
      emit(ChatLoading());
      final messages = await _chatRepository.getMessages(businessId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // Mesaj gönder
  Future<void> sendMessage({
    required String senderId,
    required String businessId,
    required String message,
  }) async {
    try {
      await _chatRepository.sendMessage(
        senderId: senderId,
        businessId: businessId,
        message: message,
      );

      final messages = await _chatRepository.getMessages(businessId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _chatRepository.markMessageAsRead(messageId);
    } catch (e) {
      print('Mesaj okundu işaretlenirken hata: $e');
    }
  }

  Future<void> markAllMessagesAsRead() async {
    try {
      await _chatRepository.markAllMessagesAsRead();
      loadChatList();
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> deleteChat(String businessId) async {
    try {
      await _chatRepository.deleteChat(businessId);
      loadChatList();
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}
