import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';  // ChatCubit'i import ediyoruz.
import 'package:letwork/features/chat/view/chat_detail_screen.dart';  // ChatDetailScreen'i import ediyoruz.
import 'package:letwork/data/model/chat_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatError) {
            return Center(child: Text('Hata: ${state.message}'));
          } else if (state is ChatLoaded) {
            final messages = state.messages;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final chat = messages[index];

                return ListTile(
                  title: Text(chat.senderName),
                  subtitle: Text(chat.message),
                  onTap: () {
                    // ChatDetailScreen'e yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(businessId: chat.businessId),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('Henüz bir mesaj yok.'));
          }
        },
      ),
    );
  }
}
