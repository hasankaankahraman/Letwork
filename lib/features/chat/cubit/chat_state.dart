part of 'chat_cubit.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> messages;
  ChatLoaded({required this.messages});
}

class ChatMessageSent extends ChatState {}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}
