import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getMessages() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        return ApiResult.error(
          data['message']?.toString() ?? 'L?i t?i tin nh?n',
        );
      }
    } catch (e) {
      return ApiResult.error('L?i t?i tin nh?n: $e');
    }
  }

  static Future<ApiResult> sendMessage(String content) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: headers,
        body: jsonEncode({'content': content}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        return ApiResult.error(
          data['message']?.toString() ?? 'L?i g?i tin nh?n',
        );
      }
    } catch (e) {
      return ApiResult.error('L?i g?i tin nh?n: $e');
    }
  }

  static Future<ApiResult> getChatSessions() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/sessions'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        return ApiResult.error(
          data['message']?.toString() ?? 'L?i t?i phiên chat',
        );
      }
    } catch (e) {
      return ApiResult.error('L?i t?i phiên chat: $e');
    }
  }

  static Future<ApiResult> getMessagesForAdmin(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$uid'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        return ApiResult.error(
          data['message']?.toString() ?? 'L?i t?i l?ch s? chat',
        );
      }
    } catch (e) {
      return ApiResult.error('L?i t?i l?ch s? chat: $e');
    }
  }

  static Future<ApiResult> replyMessage(String uid, String content) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/messages/$uid/reply'),
        headers: headers,
        body: jsonEncode({'content': content}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        return ApiResult.error(
          data['message']?.toString() ?? 'L?i tr? l?i tin nh?n',
        );
      }
    } catch (e) {
      return ApiResult.error('L?i tr? l?i tin nh?n: $e');
    }
  }
}
