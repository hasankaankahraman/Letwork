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
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final menuRaw = json['menu'];
    final imagesRaw = json['images'];

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
    );
  }
}
