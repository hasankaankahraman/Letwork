import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';

class ReviewListScreen extends StatelessWidget {
  final String businessId;

  const ReviewListScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yorumlar")),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReviewError) {
            return Center(child: Text(state.message));
          } else if (state is ReviewLoaded) {
            final reviews = state.reviews;
            final average = state.averageRating;

            if (reviews.isEmpty) {
              return const Center(child: Text("Henüz yorum yok."));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const Text("Ortalama Puan: ", style: TextStyle(fontSize: 16)),
                    Text(average.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ...List.generate(5, (i) {
                      return Icon(
                        i < average.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
                const Divider(height: 32),

                ...reviews.map((review) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment),
                          const SizedBox(height: 6),
                          Text("Kullanıcı ID: ${review.userId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
