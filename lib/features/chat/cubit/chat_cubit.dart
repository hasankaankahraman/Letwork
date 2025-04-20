import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letwork/features/chat/repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  Future<void> loadChatList() async {
    try {
      if (isClosed) return;
      emit(ChatLoading());

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        if (!isClosed) emit(ChatError(message: "Kullanıcı ID'si bulunamadı"));
        return;
      }

      print("📥 ChatCubit -> userId: $userId");

      final chats = await _chatRepository.getChatList(userId: userId);

      if (!isClosed) emit(ChatLoaded(messages: chats));
    } catch (e) {
      if (!isClosed) emit(ChatError(message: e.toString()));
    }
  }

  Future<void> loadMessages(String businessId) async {
    try {
      if (isClosed) return;
      emit(ChatLoading());

      final messages = await _chatRepository.getMessages(businessId);

      if (!isClosed) emit(ChatLoaded(messages: messages));
    } catch (e) {
      if (!isClosed) emit(ChatError(message: e.toString()));
    }
  }

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

      if (isClosed) return;

      final messages = await _chatRepository.getMessages(businessId);

      if (!isClosed) emit(ChatLoaded(messages: messages));
    } catch (e) {
      if (!isClosed) emit(ChatError(message: e.toString()));
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
      if (!isClosed) await loadChatList();
    } catch (e) {
      if (!isClosed) emit(ChatError(message: e.toString()));
    }
  }

  Future<void> deleteChat(String businessId) async {
    try {
      await _chatRepository.deleteChat(businessId);
      if (!isClosed) await loadChatList();
    } catch (e) {
      if (!isClosed) emit(ChatError(message: e.toString()));
    }
  }
}
