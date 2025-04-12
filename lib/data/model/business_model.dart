class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String profileImage;
  final double latitude;
  final double longitude;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.profileImage,
    required this.latitude,
    required this.longitude,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      profileImage: json['profile_image'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }
}
