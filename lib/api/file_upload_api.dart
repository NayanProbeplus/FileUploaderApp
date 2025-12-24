import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_uploader_app/AuthManager.dart';
import 'package:file_uploader_app/constants/env.dart';

class FileUploadApi {
  /// Step 1: Call backend → get presigned S3 URLs
  static Future<Map<String, dynamic>> uploadDocuments({
    required String patientId,
    required String prescriptionId,
    required List<Map<String, String>> docsList,
  }) async {
    final headers = await AuthManager.getAuthHeaders();
    if (headers == null) {
      throw Exception('User not authenticated');
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        ApiConstants.uploadDocuments,
        data: jsonEncode({
          "patient_id": patientId,
          "prescription_id": prescriptionId,
          "docs_list": docsList,
        }),
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('🟢 Upload Metadata Success');
      debugPrint('🟢 Status Code: ${response.statusCode}');
      debugPrint('🟢 Response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload metadata failed');
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('🔴 Upload Metadata API Error');
      debugPrint('🔴 Status Code: ${e.response?.statusCode}');
      debugPrint('🔴 Response: ${e.response?.data}');
      rethrow;
    }
  }
}

class S3Uploader {
  /// Step 2: Upload actual file to S3 using presigned PUT URL
  static Future<void> uploadFileToS3({
    required String presignedUrl,
    required File file,
  }) async {
    final dio = Dio();

    try {
      final response = await dio.put(
        presignedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': _getMimeType(file.path),
            'Content-Length': await file.length(),
          },
        ),
      );

      debugPrint('🟢 S3 Upload Success');
      debugPrint('🟢 Status Code: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('🔴 S3 Upload Failed');
      debugPrint('🔴 Message: ${e.message}');
      debugPrint('🔴 Status Code: ${e.response?.statusCode}');
      rethrow;
    }
  }

  static String _getMimeType(String path) {
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}
