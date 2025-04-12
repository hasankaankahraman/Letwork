part of 'review_cubit.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final String message;
  ReviewSuccess(this.message);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}

class ReviewLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  final double averageRating;
  ReviewLoaded(this.reviews, this.averageRating);
}
