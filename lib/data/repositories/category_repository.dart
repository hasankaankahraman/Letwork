import '../services/category_service.dart';

class CategoryRepository {
  final _service = CategoryService();

  // AddBusiness için gruplu çekiyoruz
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _service.fetchGroupedCategories();
  }
}
