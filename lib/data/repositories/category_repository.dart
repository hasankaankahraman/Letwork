import '../services/category_service.dart';

class CategoryRepository {
  final _service = CategoryService();

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _service.fetchCategories();
  }
}
