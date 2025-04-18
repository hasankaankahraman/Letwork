import 'package:dio/dio.dart';
import 'package:letwork/data/services/dio_client.dart';
import 'package:letwork/data/model/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final Dio _dio = DioClient().dio;

  // SharedPreferences'tan userId çek
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 1;
    print("🧠 SharedPreferences'tan alınan userId: $userId");
    return userId;
  }

  // Sohbet listesini getir
  Future<List<ChatModel>> fetchChatList({required int userId}) async {
    try {
      print("📨 fetchChatList için userId: $userId");

      final response = await _dio.get(
        "chat/get_user_chats.php",
        queryParameters: {"user_id": userId.toString()},
      );

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return data.map((e) => ChatModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? "Sohbet listesi alınamadı.");
      }
    } catch (e) {
      print("❌ Chat list fetch error: $e");
      throw Exception("Sohbet listesi alınamadı: $e");
    }
  }

  // Mesajları getir
  Future<List<ChatModel>> fetchMessages(String businessId) async {
    try {
      final userId = await getUserId();
      final response = await _dio.get(
        "chat/get_messages.php",
        queryParameters: {
          "business_id": businessId,
          "user_id": userId.toString(),
        },
      );

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return data.map((e) => ChatModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? "Mesajlar alınamadı.");
      }
    } catch (e) {
      print("❌ Messages fetch error: $e");
      throw Exception("Mesajlar alınamadı: $e");
    }
  }

  // Mesaj gönder
  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String businessId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        "chat/send_message.php",
        data: {
          "sender_id": senderId,
          "business_id": businessId,
          "message": message,
        },
      );

      if (response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? "Mesaj gönderilemedi.");
      }
    } catch (e) {
      print("❌ Send message error: $e");
      throw Exception("Mesaj gönderilemedi: $e");
    }
  }

  // Mesajı okundu olarak işaretle
  Future<Map<String, dynamic>> markMessageAsRead(String messageId) async {
    try {
      final response = await _dio.post(
        "chat/mark_message_read.php",
        data: {"message_id": messageId},
      );

      if (response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? "Mesaj okundu olarak işaretlenemedi.");
      }
    } catch (e) {
      print("❌ Mark message read error: $e");
      throw Exception("Mesaj okundu olarak işaretlenemedi: $e");
    }
  }

  // Tüm mesajları okundu olarak işaretle
  Future<Map<String, dynamic>> markAllMessagesAsRead() async {
    try {
      final userId = await getUserId();
      final response = await _dio.post(
        "chat/mark_all_messages_read.php",
        data: {"user_id": userId.toString()},
      );

      if (response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? "Mesajlar okundu olarak işaretlenemedi.");
      }
    } catch (e) {
      print("❌ Mark all messages read error: $e");
      throw Exception("Mesajlar okundu olarak işaretlenemedi: $e");
    }
  }

  // Sohbeti sil
  Future<Map<String, dynamic>> deleteChat(String businessId) async {
    try {
      final userId = await getUserId();
      final response = await _dio.delete(
        "chat/delete_chat.php",
        data: {
          "business_id": businessId,
          "user_id": userId.toString(),
        },
      );

      if (response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? "Sohbet silinemedi.");
      }
    } catch (e) {
      print("❌ Delete chat error: $e");
      throw Exception("Sohbet silinemedi: $e");
    }
  }
}
