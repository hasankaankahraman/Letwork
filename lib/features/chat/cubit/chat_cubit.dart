import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/chat_model.dart';
import 'package:letwork/features/chat/repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  // Mesajları yükle
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
      emit(ChatLoading());
      await _chatRepository.sendMessage(
        senderId: senderId,
        businessId: businessId,
        message: message,
      );
      emit(ChatMessageSent());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}
