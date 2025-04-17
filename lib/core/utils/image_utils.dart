// lib/core/utils/image_utils.dart
import 'dart:io';
import 'package:dio/dio.dart';

class ImageUtils {
  static Future<MultipartFile?> convertFileToMultipart(File? file) async {
    if (file == null) return null;
    return await MultipartFile.fromFile(file.path);
  }

  static Future<List<MultipartFile>> convertFilesToMultipart(List<File> files) async {
    List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      multipartFiles.add(await MultipartFile.fromFile(file.path));
    }

    return multipartFiles;
  }
}