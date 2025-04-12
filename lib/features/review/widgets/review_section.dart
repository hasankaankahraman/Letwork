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
              final userReview = reviews.firstWhere(
                    (r) => r.userId == currentUserId,
                orElse: () => ReviewModel.empty(),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Yorumlar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  if (averageRating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text("Ortalama Puan: ⭐ $averageRating"),
                        const SizedBox(width: 10),
                        ...List.generate(5, (i) {
                          return Icon(
                            i < averageRating.round() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 🙋‍♂️ Kullanıcının kendi yorumu
                  if (userReview.userId != 0) ...[
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: const Text("Senin Yorumun"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("⭐ ${userReview.rating}"),
                            const SizedBox(height: 4),
                            Text(userReview.comment),
                          ],
                        ),
                        trailing: TextButton(
                          child: const Text("Güncelle"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => ReviewCubit(ReviewRepository()),
                                  child: AddReviewScreen(
                                    businessId: businessId,
                                    userId: currentUserId.toString(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => ReviewCubit(ReviewRepository()),
                              child: AddReviewScreen(
                                businessId: businessId,
                                userId: currentUserId.toString(),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text("Yorum Yap"),
                    ),
                  ],

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ReviewCubit(ReviewRepository())..fetchReviews(businessId),
                            child: ReviewListScreen(businessId: businessId),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.reviews),
                    label: const Text("Diğer Yorumları Gör"),
                  ),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
