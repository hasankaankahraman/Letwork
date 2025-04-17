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

              final userReview = reviews.where(
                      (r) => r.userId.toString() == currentUserId.toString()
              ).firstOrNull; // firstOrNull Flutter 2.17+ ile kullanılabilir

              final hasUserReview = userReview != null;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Header
                    _buildHeader(context, reviews),

                    // Rating
                    if (averageRating > 0) _buildRatingSection(averageRating),

                    // No reviews message
                    if (reviews.isEmpty) _buildEmptyReviewsMessage(),

                    // User review or add review button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: hasUserReview
                          ? _buildUserReview(context, userReview, currentUserId)
                          : _buildAddReviewButton(context, currentUserId),
                    ),

                    const SizedBox(height: 8),

                    // View all reviews button
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
            letterSpacing: 0.2,
            color: Color(0xFFFF0000), // Kırmızı tema
          ),
        ),
        if (reviews.isNotEmpty)
          TextButton.icon(
            onPressed: () => _navigateToReviewList(context),
            icon: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFFF0000)),
            label: Text(
              "${reviews.length} Yorum",
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFFF0000)),
            ),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          )
      ],
    );
  }

  Widget _buildRatingSection(double averageRating) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50.withOpacity(0.5), // Kırmızı tema
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
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
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
            ),
          ],
        ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100, width: 1.5), // Kırmızı tema
      ),
      elevation: 0,
      // ignore: deprecated_member_use
      color: Colors.red.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.red),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewButton(BuildContext context, int userId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToAddReview(context, userId),
        icon: const Icon(Icons.rate_review, size: 20),
        label: const Text("Yorum Yap", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }

  Widget _buildViewAllReviewsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton.icon(
        onPressed: () => _navigateToReviewList(context),
        icon: const Icon(Icons.reviews_outlined),
        label: const Text("Tüm Yorumları Görüntüle"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  void _navigateToAddReview(BuildContext context, int userId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReviewCubit>(),
          child: AddReviewScreen(
            businessId: businessId,
            userId: userId.toString(),
          ),
        ),
      ),
    );

    if (result == true) {
      context.read<ReviewCubit>().fetchReviews(businessId);
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

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
