import 'dart:async';
import 'package:flutter_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static const String tokenKey = 'jwt_access_token';
  static const Duration timeout = Duration(seconds: 120);

  /// Gui ping danh thuc server Render khi mo app.
  static Future<void> warmUp() async {
    try {
      http
          .get(Uri.parse('$baseUrl/products?limit=1'))
          .timeout(const Duration(seconds: 120));
    } catch (_) {}
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
