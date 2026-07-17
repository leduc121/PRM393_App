import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getNotifications() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/notifications'), headers: headers)
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i thông báo';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i thông báo: $e');
    }
  }

  static Future<ApiResult> markNotificationRead(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .patch(Uri.parse('$baseUrl/notifications/$id/read'), headers: headers)
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? dánh d?u thông báo dã d?c';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t thông báo: $e');
    }
  }

  static Future<ApiResult> markAllNotificationsRead() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .patch(Uri.parse('$baseUrl/notifications/read-all'), headers: headers)
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? dánh d?u t?t c? dã d?c';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t thông báo: $e');
    }
  }

  static Future<ApiResult> deleteNotification(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/notifications/$id'), headers: headers)
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? xóa thông báo';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa thông báo: $e');
    }
  }

  static Future<ApiResult> clearNotifications() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/notifications/clear-all'),
            headers: headers,
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? xóa t?t c? thông báo';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa t?t c? thông báo: $e');
    }
  }
}
