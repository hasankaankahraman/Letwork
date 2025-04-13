class BusinessModel {
  final String id;
  final String userId; // 👈 EKLENDİ
  final String name;
  final String description;
  final String address;
  final String category;
  final String subCategory;
  final String profileImage;
  final String ownerName;
  final double latitude;
  final double longitude;
  final double? distance;
  final String? menuRaw;

  BusinessModel({
    required this.id,
    required this.userId, // 👈 EKLENDİ
    required this.name,
    required this.description,
    required this.address,
    required this.category,
    required this.subCategory,
    required this.profileImage,
    required this.ownerName,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.menuRaw,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(), // 👈 EKLENDİ
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      profileImage: json['profile_image'] ?? '',
      ownerName: json['owner_name'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
      menuRaw: json['menu']?.toString(),
    );
  }

  String get profileImageUrl {
    return profileImage.isNotEmpty
        ? "https://letwork.hasankaan.com/$profileImage"
        : "https://letwork.hasankaan.com/assets/default_profile.png";
  }
}
