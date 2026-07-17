import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> createOrder({
    required String addressId,
    required String paymentMethod,
    String? note,
    String? voucherId,
    int? shippingFee,
    double? deliveryLatitude,
    double? deliveryLongitude,
    double? deliveryDistanceKm,
  }) async {
    try {
      final headers = await _authHeaders();
      final body = <String, dynamic>{
        'addressId': addressId,
        'paymentMethod': paymentMethod,
      };
      if (note != null && note.isNotEmpty) body['note'] = note;
      if (voucherId != null && voucherId.isNotEmpty) {
        body['voucherId'] = voucherId;
      }
      if (shippingFee != null) body['shippingFee'] = shippingFee;
      if (deliveryLatitude != null) {
        body['deliveryLatitude'] = deliveryLatitude;
      }
      if (deliveryLongitude != null) {
        body['deliveryLongitude'] = deliveryLongitude;
      }
      if (deliveryDistanceKm != null) {
        body['deliveryDistanceKm'] = deliveryDistanceKm;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Ð?t hàng th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i d?t hàng: $e');
    }
  }

  static Future<ApiResult> createStripeCheckoutSession(String orderId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-checkout-session/$orderId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? kh?i t?o thanh toán Stripe';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?o phiên thanh toán: $e');
    }
  }

  static Future<ApiResult> getMyOrders() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i danh sách don hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i danh sách don hàng: $e');
    }
  }

  static Future<ApiResult> getAllOrders() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/all'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i danh sách don hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i danh sách don hàng: $e');
    }
  }

  static Future<ApiResult> getOrderById(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không th? t?i chi ti?t don hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i t?i chi ti?t don hàng: $e');
    }
  }

  static Future<ApiResult> cancelOrder(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'H?y don hàng th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i h?y don hàng: $e');
    }
  }

  static Future<ApiResult> approveCancelOrder(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$id/approve-cancel'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Duyet hoan tien that bai';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Loi duyet huy don: $e');
    }
  }

  static Future<ApiResult> abandonOrder(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id/abandon'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'H?y don hàng th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i h?y don hàng: $e');
    }
  }

  static Future<ApiResult> updateOrderStatus(String id, String status) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'C?p nh?t tr?ng thái th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i c?p nh?t tr?ng thái don hàng: $e');
    }
  }
}
