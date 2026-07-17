import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class UserApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getUserProfile(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$uid'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? l?y thông tin ngu?i dùng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i l?y thông tin ngu?i dùng: $e');
    }
  }

  static Future<ApiResult> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$uid'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'C?p nh?t profile th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t profile: $e');
    }
  }

  static Future<ApiResult> getAddresses(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$uid/addresses'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i danh sách d?a ch?';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i danh sách d?a ch?: $e');
    }
  }

  static Future<ApiResult> createAddress({
    required String uid,
    required String recipientName,
    required String phone,
    required String street,
    String? ward,
    String? district,
    String? city,
    bool isDefault = false,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users/$uid/addresses'),
        headers: headers,
        body: jsonEncode({
          'recipientName': recipientName,
          'phone': phone,
          'street': street,
          if (ward != null && ward.isNotEmpty) 'ward': ward,
          if (district != null && district.isNotEmpty) 'district': district,
          if (city != null && city.isNotEmpty) 'city': city,
          'isDefault': isDefault,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?o d?a ch?';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?o d?a ch?: $e');
    }
  }

  static Future<ApiResult> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Không th? c?p nh?t d?a ch?';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t d?a ch?: $e');
    }
  }

  static Future<ApiResult> deleteAddress(String addressId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? xóa d?a ch?';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa d?a ch?: $e');
    }
  }
}
