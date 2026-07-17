import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class AdminProductApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> uploadProductImage(
    String filePath, {
    List<int>? bytes,
    String? fileName,
  }) async {
    try {
      final headers = await _authHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products/upload'),
      );
      if (headers['Authorization'] != null) {
        request.headers['Authorization'] = headers['Authorization']!;
      }
      if (kIsWeb && bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName ?? 'upload.png',
          ),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Upload th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i upload: $e');
    }
  }

  static Future<ApiResult> createProduct(Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Thêm s?n ph?m th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> getProductDetail(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$id'))
          .timeout(_timeout);
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'L?y chi ti?t s?n ph?m th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'C?p nh?t th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> deleteProduct(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Xóa th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }
}
