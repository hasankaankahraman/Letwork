part of 'chat_cubit.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<dynamic> messages;
  ChatLoaded({required this.messages});
}

class ChatMessageSent extends ChatState {}

class ChatListLoaded extends ChatState {
  final List<dynamic> chatList;
  ChatListLoaded({required this.chatList});
}

class ChatMessageMarkedAsRead extends ChatState {}

class ChatAllMessagesMarkedAsRead extends ChatState {}

class ChatDeleted extends ChatState {}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}