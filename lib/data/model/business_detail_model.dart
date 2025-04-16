class BusinessDetailModel {
  final String id;
  final String userId;       // userId ekleniyor
  final String name;
  final String description;
  final String category;
  final String subCategory;
  final String address;
  final String openTime;
  final String closeTime;
  final List<dynamic> images;
  final List<dynamic> menu;
  final List<dynamic> services; // EKLENDİ
  final double latitude;
  final double longitude;

  // Yeni eklenen alanlar
  final String profileImage;  // Profil resmi
  final String ownerName;     // Sahip adı
  bool isFavorite;            // Favori durumu

  // Eklenen yeni alanlar:
  final bool isCorporate; // Kurumsal mı?
  final List<String> detailImages; // Detaylı resimler

  BusinessDetailModel({
    required this.id,
    required this.userId,      // userId parametresi ekleniyor
    required this.name,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.images,
    required this.menu,
    required this.services, // EKLENDİ
    required this.latitude,
    required this.longitude,
    required this.profileImage,  // Profil resmi
    required this.ownerName,     // Sahip adı
    required this.isCorporate,   // Kurumsal mı?
    required this.detailImages,  // Detaylı resimler
    this.isFavorite = false,    // Varsayılan olarak false
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final menuRaw = json['menu'];
    final imagesRaw = json['images'];
    final servicesRaw = json['services']; // EKLENDİ
    final detailImagesRaw = json['detail_images']; // EKLENDİ

    return BusinessDetailModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),  // userId burada ekleniyor
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      address: json['address'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      images: imagesRaw is List ? imagesRaw : [],
      menu: menuRaw is List ? menuRaw : [],
      services: servicesRaw is List ? servicesRaw : [], // EKLENDİ
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      profileImage: json['profile_image'] ?? '',  // Profil resmi
      ownerName: json['owner_name'] ?? '',       // Sahip adı
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1, // Favori durumu
      isCorporate: json['is_corporate'] == 1,    // Kurumsal mı?
      detailImages: detailImagesRaw is List ? List<String>.from(detailImagesRaw) : [], // Detay resimler
    );
  }

  String get profileImageUrl {
    return profileImage.isNotEmpty
        ? "https://letwork.hasankaan.com/$profileImage"
        : "https://letwork.hasankaan.com/assets/default_profile.png";
  }
}
