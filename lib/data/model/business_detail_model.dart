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
  final List<dynamic> images; // ✅ List<Map> yerine List<dynamic> tanımladık
  final List<dynamic> menu;
  final List<dynamic> services;
  final double latitude;
  final double longitude;
  final String profileImage;
  final String ownerName;
  bool isFavorite;
  final bool isCorporate;
  final List<String> detailImages;

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
    final imagesRaw = json['images'] ?? [];

    // JSON'dan gelen resimleri güvenli şekilde parse et
    final List<Map<String, dynamic>> parsedImages = imagesRaw is List
        ? imagesRaw
        .whereType<Map<String, dynamic>>()
        .toList()
        : [];

    final profile = parsedImages.firstWhere(
          (img) => img['is_profile'] == 1,
      orElse: () => {"image_url": ""},
    );

    final detailImgs = parsedImages
        .where((img) => img['is_profile'] == 0)
        .map<String>((img) => img['image_url'].toString())
        .toList();

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
      images: imagesRaw, // 💥 burası artık List<dynamic>
      menu: json['menu'] is List ? json['menu'] : [],
      services: json['services'] is List ? json['services'] : [],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      profileImage: profile['image_url'] ?? '',
      detailImages: detailImgs,
      ownerName: json['owner_name'] ?? '',
      isCorporate: json['is_corporate'] == 1,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
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
