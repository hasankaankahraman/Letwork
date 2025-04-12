import 'package:dio/dio.dart';
import 'package:letwork/data/services/dio_client.dart';

class ReviewService {
  final Dio _dio = DioClient().dio;

  Future<void> addOrUpdateReview({
    required String userId,
    required String businessId,
    required int rating,
    required String comment,
  }) async {
    await _dio.post("review/add_or_update_review.php", data: {
      "user_id": userId,
      "business_id": businessId,
      "rating": rating,
      "comment": comment,
    });
  }

  Future<void> deleteReview(String userId, String businessId) async {
    await _dio.post("review/delete_review.php", data: {
      "user_id": userId,
      "business_id": businessId,
    });
  }

  Future<Map<String, dynamic>> fetchReviews(String businessId) async {
    final res = await _dio.get("review/get_reviews.php", queryParameters: {
      "business_id": businessId,
    });

    return res.data;
  }
}
