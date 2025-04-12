import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/review_model.dart';
import 'package:letwork/features/review/repository/review_repository.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository repository;

  ReviewCubit(this.repository) : super(ReviewInitial());

  Future<void> addOrUpdateReview({
    required String userId,
    required String businessId,
    required int rating,
    required String comment,
  }) async {
    try {
      emit(ReviewLoading());
      await repository.addOrUpdateReview(
        userId: userId,
        businessId: businessId,
        rating: rating,
        comment: comment,
      );
      emit(ReviewSuccess("Yorum başarıyla eklendi/güncellendi."));
    } catch (e) {
      emit(ReviewError("Yorum eklenemedi: ${e.toString()}"));
    }
  }

  Future<void> deleteReview(String userId, String businessId) async {
    try {
      emit(ReviewLoading());
      await repository.deleteReview(userId, businessId);
      emit(ReviewSuccess("Yorum silindi."));
    } catch (e) {
      emit(ReviewError("Yorum silinemedi: ${e.toString()}"));
    }
  }

  Future<void> fetchReviews(String businessId) async {
    try {
      emit(ReviewLoading());
      final reviews = await repository.fetchReviews(businessId);
      final averageRating = _calculateAverageRating(reviews);
      emit(ReviewLoaded(reviews, averageRating));
    } catch (e) {
      emit(ReviewError("Yorumlar alınamadı: ${e.toString()}"));
    }
  }

  double _calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
