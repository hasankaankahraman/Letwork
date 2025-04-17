class BusinessDetailModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String category;
  final String subCategory;
  final String address;
  final String openTime;
  final String closeTime;
  final List<dynamic> images;
  final List<dynamic> menu;
  final List<dynamic> services;
  final double latitude;
  final double longitude;
  final String profileImage;
  final String ownerName;
  bool isFavorite;
  final bool isCorporate;
  final List<String> detailImages;

  // Yeni alanlar
  final String? phone;
  final String? email;
  final String? website;

  BusinessDetailModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.images,
    required this.menu,
    required this.services,
    required this.latitude,
    required this.longitude,
    required this.profileImage,
    required this.ownerName,
    required this.isCorporate,
    required this.detailImages,
    this.isFavorite = false,
    this.phone,
    this.email,
    this.website,
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final menuRaw = json['menu'];
    final imagesRaw = json['images'];
    final servicesRaw = json['services'];
    final detailImagesRaw = json['detail_images'];

    return BusinessDetailModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      address: json['address'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      images: imagesRaw is List ? imagesRaw : [],
      menu: menuRaw is List ? menuRaw : [],
      services: servicesRaw is List ? servicesRaw : [],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      profileImage: json['profile_image'] ?? '',
      ownerName: json['owner_name'] ?? '',
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      isCorporate: json['is_corporate'] == 1,
      detailImages: detailImagesRaw is List ? List<String>.from(detailImagesRaw) : [],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
    );
  }

  String get profileImageUrl {
    return profileImage.isNotEmpty
        ? "https://letwork.hasankaan.com/$profileImage"
        : "https://letwork.hasankaan.com/assets/default_profile.png";
  }
}
