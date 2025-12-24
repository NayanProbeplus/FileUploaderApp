import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_uploader_app/AuthManager.dart';

class FileUploadApi {
  static const String _baseUrl =
      'http://10.10.3.30:9010/api/v1/documents/upload';

  static Future<void> uploadDocuments({
    required String patientId,
    required String prescriptionId,
    required List<File> files,
  }) async {
    // 🔐 Get valid token (auto refresh if needed)
    final headers = await AuthManager.getAuthHeaders();

    if (headers == null) {
      throw Exception('User not authenticated');
    }

    final dio = Dio();

    // Build docs_list metadata
    final docsList = files.map((file) {
      return {
        "file_name": path.basename(file.path),
        "file_size": file.lengthSync().toString(),
        "file_type": path.extension(file.path).replaceFirst('.', ''),
      };
    }).toList();

    final formData = FormData.fromMap({
      "patient_id": patientId,
      "prescription_id": prescriptionId,
      "docs_list": docsList,
      "files": files
          .map(
            (file) => MultipartFile.fromFileSync(
              file.path,
              filename: path.basename(file.path),
            ),
          )
          .toList(),
    });

    try {
      final response = await dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {
            ...headers, // 🔑 Authorization header
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // ✅ SUCCESS LOGS
      debugPrint('🟢 Upload Success');
      debugPrint('🟢 Status Code: ${response.statusCode}');
      debugPrint('🟢 Response Headers: ${response.headers}');
      debugPrint('🟢 Response Body: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Upload failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // ❌ API ERROR LOGS
      debugPrint('🔴 Upload API Error');
      debugPrint('🔴 Message: ${e.message}');
      debugPrint('🔴 Status Code: ${e.response?.statusCode}');
      debugPrint('🔴 Response Data: ${e.response?.data}');
      debugPrint('🔴 Headers: ${e.response?.headers}');
      rethrow;
    } catch (e) {
      // ❌ UNKNOWN ERROR
      debugPrint('🔴 Unexpected Error: $e');
      rethrow;
    }
  }
}
