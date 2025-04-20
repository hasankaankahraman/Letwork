import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/core/utils/user_session.dart';
import 'package:letwork/data/model/review_model.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';
import 'package:letwork/features/review/repository/review_repository.dart';
import 'package:letwork/features/review/view/add_review_screen.dart';
import 'package:letwork/features/review/view/review_list_screen.dart';

class ReviewSection extends StatelessWidget {
  final String businessId;

  static const Color pureRed = Color(0xFFFF0000);
  static const Color brightYellow = Color(0xFFFFD700);

  const ReviewSection({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReviewError) {
          return Center(child: Text(state.message));
        } else if (state is ReviewLoaded) {
          final reviews = state.reviews;
          final averageRating = state.averageRating;

          return FutureBuilder<int?>(
            future: UserSession.getUserId(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final currentUserId = snapshot.data!;
              final userReview = reviews.where((r) => r.userId.toString() == currentUserId.toString()).firstOrNull;
              final hasUserReview = userReview != null;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(context, reviews),
                    if (averageRating > 0) _buildRatingSection(averageRating),
                    if (reviews.isEmpty) _buildEmptyReviewsMessage(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: hasUserReview
                          ? _buildUserReview(context, userReview!, currentUserId)
                          : _buildAddReviewButton(context, currentUserId),
                    ),
                    const SizedBox(height: 8),
                    if (reviews.isNotEmpty && reviews.length > 1)
                      _buildViewAllReviewsButton(context),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context, List<ReviewModel> reviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Yorumlar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: pureRed,
          ),
        ),
        if (reviews.isNotEmpty)
          TextButton.icon(
            onPressed: () => _navigateToReviewList(context),
            icon: const Icon(Icons.chevron_right, size: 18, color: pureRed),
            label: Text(
              "${reviews.length} Yorum",
              style: const TextStyle(fontWeight: FontWeight.w500, color: pureRed),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSection(double averageRating) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: pureRed.withOpacity(0.4), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: pureRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pureRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: brightYellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                return Icon(
                  i < averageRating.round() ? Icons.star : Icons.star_border,
                  color: brightYellow,
                  size: 20,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.comment_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "Henüz yorum yok.",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserReview(BuildContext context, ReviewModel review, int userId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: pureRed.withOpacity(0.4), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: pureRed.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: pureRed.withOpacity(0.1),
                      child: const Icon(Icons.person, color: pureRed),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Senin Yorumun",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                _buildRatingStars(review.rating),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddReview(context, userId),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text("Yorumu Güncelle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: pureRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, userId.toString()),
              icon: const Icon(Icons.delete_outline, color: pureRed),
              label: const Text("Yorumu Sil", style: TextStyle(color: pureRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: pureRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewButton(BuildContext context, int userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToAddReview(context, userId),
        icon: const Icon(Icons.rate_review, size: 20),
        label: const Text("Yorum Yap", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: pureRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }

  Widget _buildViewAllReviewsButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _navigateToReviewList(context),
      icon: const Icon(Icons.reviews_outlined, color: pureRed),
      label: const Text("Tüm Yorumları Görüntüle", style: TextStyle(color: pureRed)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: pureRed),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  void _navigateToAddReview(BuildContext context, int userId) async {
    final cubit = context.read<ReviewCubit>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddReviewScreen(
            businessId: businessId,
            userId: userId.toString(),
          ),
        ),
      ),
    );

    if (result == true) {
      cubit.fetchReviews(businessId);
    }
  }

  void _navigateToReviewList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReviewCubit(ReviewRepository())..fetchReviews(businessId),
          child: ReviewListScreen(businessId: businessId),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yorumu Sil"),
        content: const Text("Yorumu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cubit = context.read<ReviewCubit>();
              await cubit.deleteReview(userId, businessId);
              await cubit.fetchReviews(businessId);
            },
            child: const Text("Sil", style: TextStyle(color: pureRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: brightYellow,
          size: 18,
        );
      }),
    );
  }
}
