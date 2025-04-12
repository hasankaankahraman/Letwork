class ReviewModel {
  final String userId;
  final String userName;
  final String comment;
  final int rating;
  final String createdAt;

  ReviewModel({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userId: json['user_id'].toString(),
      userName: json['user_name'] ?? "Anonim",
      comment: json['comment'],
      rating: int.parse(json['rating'].toString()),
      createdAt: json['created_at'],
    );
  }

  factory ReviewModel.empty() {
    return ReviewModel(
      userId: '',
      userName: '',
      comment: '',
      rating: 0,
      createdAt: '',
    );
  }

  bool get isEmpty => userId.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
