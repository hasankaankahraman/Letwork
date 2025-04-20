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
  static const Color pureRed = Color(0xFFFF0000);
  static const Color brightYellow = Color(0xFFFFE700);

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().fetchReviews(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Değerlendirmeler",
          style: TextStyle(color: pureRed),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: pureRed),
      ),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReviewError) {
            return _buildErrorState(theme, state.message);
          } else if (state is ReviewLoaded) {
            final reviews = state.reviews;
            final average = state.averageRating > 0 ? state.averageRating : 0.0;

            if (reviews.isEmpty) {
              return _buildEmptyState(theme);
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAverageBox(theme, average, reviews.length)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => ReviewCard(review: reviews[index]),
                      childCount: reviews.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }

          return const Center(child: Text("Değerlendirmeler yükleniyor..."));
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: pureRed),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ReviewCubit>().fetchReviews(widget.businessId);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Yeniden Dene"),
            style: ElevatedButton.styleFrom(
              backgroundColor: pureRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("Henüz değerlendirme yok", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "İlk değerlendirmeyi siz yapın!",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageBox(ThemeData theme, double average, int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: pureRed.withOpacity(0.3),
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
              color: pureRed,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66FFF700),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  i < average.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: brightYellow,
                  size: 28,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            "$count değerlendirme",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  static const Color brightYellow = Color(0xFFFFE700);

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String formattedDate = '';
    try {
      final date = review.createdAt;
      formattedDate = DateFormat('dd MMM yyyy').format(date as DateTime);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kullanıcı ${review.userName}",
                style: theme.textTheme.titleSmall,
              ),
              Row(
                children: List.generate(5, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x55FFF700),
                          blurRadius: 15,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: brightYellow,
                      size: 18,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: theme.textTheme.bodyMedium),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              formattedDate,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ]
        ],
      ),
    );
  }
}
