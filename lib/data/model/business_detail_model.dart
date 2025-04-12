class BusinessDetailModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subCategory;
  final String address;
  final String openTime;
  final String closeTime;
  final List<dynamic> images;
  final List<dynamic> menu;
  final List<dynamic> services; // 👈 EKLENDİ
  final double latitude;
  final double longitude;

  BusinessDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.images,
    required this.menu,
    required this.services, // 👈 EKLENDİ
    required this.latitude,
    required this.longitude,
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final menuRaw = json['menu'];
    final imagesRaw = json['images'];
    final servicesRaw = json['services']; // 👈 EKLENDİ

    return BusinessDetailModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      address: json['address'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      images: imagesRaw is List ? imagesRaw : [],
      menu: menuRaw is List ? menuRaw : [],
      services: servicesRaw is List ? servicesRaw : [], // 👈 EKLENDİ
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }
}
