import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/dio_client.dart';

class BusinessService {
  final Dio _dio = DioClient().dio;

  Future<BusinessDetailModel> fetchBusinessDetail(String id) async {
    final response = await _dio.get("business/get_business_detail.php", queryParameters: {
      "business_id": id,
    });

    if (response.data['status'] == 'success') {
      return BusinessDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message']);
    }
  }

  Future<List<BusinessModel>> fetchAllBusinesses() async {
    final response = await _dio.get("business/get_business.php");

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception("İşletmeler alınamadı");
    }
  }
}
