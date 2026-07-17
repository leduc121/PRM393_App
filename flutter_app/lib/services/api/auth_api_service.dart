import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<void> saveToken(String token) => ApiClient.saveToken(token);
  static Future<String?> getToken() => ApiClient.getToken();
  static Future<void> clearToken() => ApiClient.clearToken();
  static Future<ApiResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'password': password,
              if (phone != null && phone.isNotEmpty) 'phone': phone,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Ðang ký th?t b?i';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } on TimeoutException {
      return ApiResult.error('Server ph?n h?i quá lâu. Vui lòng th? l?i.');
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i d?n server: $e');
    }
  }

  static Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await saveToken(token.toString());
        }
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Ðang nh?p th?t b?i';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } on TimeoutException {
      return ApiResult.error('Server ph?n h?i quá lâu. Vui lòng th? l?i.');
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i d?n server: $e');
    }
  }

  static Future<ApiResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await saveToken(token.toString());
        }
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Xác th?c th?t b?i';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } on TimeoutException {
      return ApiResult.error('Server ph?n h?i quá lâu. Vui lòng th? l?i.');
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> resendOtp({required String email}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/resend-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'G?i l?i th?t b?i';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } on TimeoutException {
      return ApiResult.error('Server ph?n h?i quá lâu. Vui lòng th? l?i.');
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> logout() async {
    try {
      final headers = await _authHeaders();
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
      await clearToken();
      return ApiResult.success(null);
    } catch (e) {
      await clearToken();
      return ApiResult.success(null);
    }
  }

  static Future<ApiResult> getMe() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Token h?t h?n');
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }
}
