import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/dio_client.dart';

class HomeRepository {
  final Dio _dio = DioClient().dio;

  Future<List<BusinessModel>> fetchBusinesses() async {
    final response = await _dio.get("business/get_business.php");

    if (response.data['status'] == 'success') {
      final List list = response.data['data'];
      return list.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message']);
    }
  }
}
