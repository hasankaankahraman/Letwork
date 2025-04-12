class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String profileImage;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.profileImage,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'].toString(),
      name: json['name'],
      category: json['category'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }
}
