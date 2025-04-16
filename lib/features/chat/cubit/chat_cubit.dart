import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/chat_model.dart';
import 'package:letwork/features/chat/repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  // Sohbet listesini yükle
  Future<void> loadChatList() async {
    try {
      emit(ChatLoading());
      final chats = await _chatRepository.getChatList();
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
      // Yükleme durumuna geçmiyoruz çünkü zaten mesajlar yüklendi
      await _chatRepository.sendMessage(
        senderId: senderId,
        businessId: businessId,
        message: message,
      );

      // Mesaj gönderildikten sonra mesajları tekrar yükle
      final messages = await _chatRepository.getMessages(businessId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // Mesajı okundu olarak işaretle
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _chatRepository.markMessageAsRead(messageId);
      // State'i güncellemeye gerek yok, çünkü bu genelde arka planda çalışır
    } catch (e) {
      // Hata durumunda sessizce devam et ya da loglama yap
      print('Mesaj okundu işaretlenirken hata: $e');
    }
  }

  // Tüm mesajları okundu olarak işaretle
  Future<void> markAllMessagesAsRead() async {
    try {
      await _chatRepository.markAllMessagesAsRead();
      // Sohbet listesini güncellemek için tekrar yükle
      loadChatList();
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  // Sohbeti sil
  Future<void> deleteChat(String businessId) async {
    try {
      await _chatRepository.deleteChat(businessId);
      // Sohbet listesini güncellemek için tekrar yükle
      loadChatList();
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}