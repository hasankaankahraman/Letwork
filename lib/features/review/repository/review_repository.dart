import 'package:letwork/data/model/review_model.dart';
import 'package:letwork/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService _service = ReviewService();

  Future<void> addOrUpdateReview({
    required String userId,
    required String businessId,
    required int rating,
    required String comment,
  }) async {
    await _service.addOrUpdateReview(
      userId: userId,
      businessId: businessId,
      rating: rating,
      comment: comment,
    );
  }

  Future<void> deleteReview(String userId, String businessId) async {
    await _service.deleteReview(userId, businessId);
  }

  Future<List<ReviewModel>> fetchReviews(String businessId) async {
    final response = await _service.fetchReviews(businessId);

    if (response['status'] == 'success') {
      final data = response['data'];
      final List reviews = data['reviews']; // ✅ burası düzeltildi
      return reviews.map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      throw Exception("Yorumlar getirilemedi.");
    }
  }

}
