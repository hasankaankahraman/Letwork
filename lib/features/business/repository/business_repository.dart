import 'package:letwork/data/services/business_service.dart';

class BusinessRepository {
  final BusinessService _service = BusinessService();

  Future<Map<String, dynamic>> addBusiness(Map<String, dynamic> data) async {
    final response = await _service.addBusiness(data);
    return response.data;
  }
}
