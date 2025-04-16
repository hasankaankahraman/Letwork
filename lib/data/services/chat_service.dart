import 'package:dio/dio.dart';
import 'package:letwork/data/services/dio_client.dart';
import 'package:letwork/data/model/chat_model.dart';

class ChatService {
  final Dio _dio = DioClient().dio;

  // Mesaj gönderme
  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String businessId,
    required String message,
  }) async {
    final response = await _dio.post(
      "chat/send_message.php",
      data: {
        "sender_id": senderId,
        "business_id": businessId,
        "message": message,
      },
    );

    return response.data;
  }

  // İşletme ile mesajları çekme
  Future<List<ChatModel>> fetchMessages(String businessId) async {
    final response = await _dio.get("chat/get_messages.php", queryParameters: {
      "business_id": businessId,
    });

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => ChatModel.fromJson(e)).toList();
    } else {
      throw Exception("Mesajlar alınamadı.");
    }
  }
}
