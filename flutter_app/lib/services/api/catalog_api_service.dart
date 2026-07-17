import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:http/http.dart' as http;

class CatalogApiService {
  static String get baseUrl => ApiClient.baseUrl;
  static Duration get _timeout => ApiClient.timeout;
  static Future<Map<String, String>> _authHeaders() => ApiClient.authHeaders();
  static Future<ApiResult> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? brandId,
    int? minPrice,
    int? maxPrice,
    String? gender,
    String? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        // ignore: use_null_aware_elements
        if (categoryId case final id?) 'category_id': id,
        // ignore: use_null_aware_elements
        if (brandId case final id?) 'brand_id': id,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (size != null && size.isNotEmpty) 'size': size,
      };

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không th? t?i danh sách s?n ph?m');
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> getCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/categories'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không th? t?i danh m?c');
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> getBrands() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/brands'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không th? t?i thuong hi?u');
      }
    } catch (e) {
      return ApiResult.error('Không th? k?t n?i: $e');
    }
  }

  static Future<ApiResult> createBrand(String name) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/brands'),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Thêm thuong hi?u th?t b?i';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('L?i thêm thuong hi?u: $e');
    }
  }
}
