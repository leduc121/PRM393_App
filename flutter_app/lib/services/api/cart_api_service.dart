import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class CartApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getCart() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/cart'), headers: headers)
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i gi? hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i gi? hàng: $e');
    }
  }

  static Future<ApiResult> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/cart/items'),
            headers: headers,
            body: jsonEncode({'variantId': variantId, 'quantity': quantity}),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? thêm vào gi? hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i thêm vào gi? hàng: $e');
    }
  }

  static Future<ApiResult> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/cart/items/$itemId'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? c?p nh?t gi? hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t gi? hàng: $e');
    }
  }

  static Future<ApiResult> deleteCartItem({required String itemId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/items/$itemId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? xóa m?t hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa m?t hàng: $e');
    }
  }

  static Future<ApiResult> clearCart() async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? xóa toàn b? gi? hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i xóa toàn b? gi? hàng: $e');
    }
  }
}
