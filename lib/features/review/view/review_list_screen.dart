import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';
import 'package:letwork/data/model/review_model.dart';
import 'package:intl/intl.dart';

class ReviewListScreen extends StatefulWidget {
  final String businessId;

  const ReviewListScreen({super.key, required this.businessId});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  void initState() {
    super.initState();
    // Load reviews when screen initializes
    context.read<ReviewCubit>().fetchReviews(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Değerlendirmeler"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFF0000), // Kırmızı tema
      ),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ReviewError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ReviewCubit>().fetchReviews(widget.businessId);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Yeniden Dene"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFFF0000), // Kırmızı tema
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ReviewLoaded) {
            final reviews = state.reviews;
            final average = state.averageRating > 0 ? state.averageRating : 0.0;

            if (reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Henüz değerlendirme yok",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "İlk değerlendirmeyi siz yapın!",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          average.toStringAsFixed(1),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF0000), // Kırmızı tema
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < average.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 28,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${reviews.length} değerlendirme",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final review = reviews[index];
                        return ReviewCard(review: review);
                      },
                      childCount: reviews.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            );
          }

          // Initial state or other states
          return const Center(
            child: Text("Değerlendirmeler yükleniyor..."),
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date if available
    String formattedDate = '';
    if (review.createdAt != null) {
      try {
        final date = review.createdAt!;
        formattedDate = DateFormat('dd MMM yyyy').format(date as DateTime);
      } catch (e) {
        // Handle date formatting errors silently
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                // User ID - you might want to display a username instead if available
                Text(
                  "Kullanıcı ${review.userId.toString().length > 4 ? review.userId.toString().substring(0, 4) : review.userId.toString()}...",
                  style: theme.textTheme.titleSmall,
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
