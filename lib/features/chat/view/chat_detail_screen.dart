import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // BlocBuilder'ı import ediyoruz.
import 'package:letwork/features/chat/cubit/chat_cubit.dart';  // ChatCubit'i import ediyoruz.

class ChatDetailScreen extends StatefulWidget {
  final String businessId;

  const ChatDetailScreen({super.key, required this.businessId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // İşletme ile mesajları yükleyelim
    context.read<ChatCubit>().loadMessages(widget.businessId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatError) {
                  return Center(child: Text('Hata: ${state.message}'));
                } else if (state is ChatLoaded) {
                  final messages = state.messages;

                  return ListView.builder(
                    reverse: true,  // En son mesajı en üstte göster
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final chat = messages[index];

                      return ListTile(
                        title: Text(chat.senderName),
                        subtitle: Text(chat.message),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Henüz bir mesaj yok.'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      context.read<ChatCubit>().sendMessage(
                        senderId: 'userId',  // Kullanıcı ID'sini buraya ekleyin.
                        businessId: widget.businessId,
                        message: message,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
