import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class VoucherApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getMyVouchers() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/vouchers/my'), headers: headers)
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i voucher';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i voucher: $e');
    }
  }

  static Future<ApiResult> getAllVouchers() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/vouchers/all'), headers: headers)
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i voucher';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i voucher: $e');
    }
  }

  static Future<ApiResult> createVoucher(Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/vouchers'),
        headers: headers,
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'T?o voucher th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?o voucher: $e');
    }
  }

  static Future<ApiResult> updateVoucher(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/vouchers/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'C?p nh?t voucher th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t voucher: $e');
    }
  }

  static Future<ApiResult> deleteVoucher(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/vouchers/$id'),
        headers: headers,
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Xóa voucher th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa voucher: $e');
    }
  }
}
