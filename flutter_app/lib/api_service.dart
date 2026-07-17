import 'package:flutter_app/services/api/admin_product_api_service.dart';
import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_result.dart';
import 'package:flutter_app/services/api/auth_api_service.dart';
import 'package:flutter_app/services/api/cart_api_service.dart';
import 'package:flutter_app/services/api/catalog_api_service.dart';
import 'package:flutter_app/services/api/chat_api_service.dart';
import 'package:flutter_app/services/api/notification_api_service.dart';
import 'package:flutter_app/services/api/order_api_service.dart';
import 'package:flutter_app/services/api/user_api_service.dart';
import 'package:flutter_app/services/api/voucher_api_service.dart';

export 'package:flutter_app/services/api/api_result.dart';

class ApiService {
  static String get baseUrl => ApiClient.baseUrl;

  static Future<void> warmUp() => ApiClient.warmUp();
  static Future<void> saveToken(String token) => ApiClient.saveToken(token);
  static Future<String?> getToken() => ApiClient.getToken();
  static Future<void> clearToken() => ApiClient.clearToken();

  static Future<ApiResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) => AuthApiService.register(
    fullName: fullName,
    email: email,
    password: password,
    phone: phone,
  );

  static Future<ApiResult> login({
    required String email,
    required String password,
  }) => AuthApiService.login(email: email, password: password);
  static Future<ApiResult> verifyOtp({
    required String email,
    required String otp,
  }) => AuthApiService.verifyOtp(email: email, otp: otp);
  static Future<ApiResult> resendOtp({required String email}) =>
      AuthApiService.resendOtp(email: email);
  static Future<ApiResult> logout() => AuthApiService.logout();
  static Future<ApiResult> getMe() => AuthApiService.getMe();

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
  }) => CatalogApiService.getProducts(
    page: page,
    limit: limit,
    search: search,
    categoryId: categoryId,
    brandId: brandId,
    minPrice: minPrice,
    maxPrice: maxPrice,
    gender: gender,
    size: size,
  );
  static Future<ApiResult> getCategories() => CatalogApiService.getCategories();
  static Future<ApiResult> getBrands() => CatalogApiService.getBrands();
  static Future<ApiResult> createBrand(String name) =>
      CatalogApiService.createBrand(name);

  static Future<ApiResult> uploadProductImage(
    String filePath, {
    List<int>? bytes,
    String? fileName,
  }) => AdminProductApiService.uploadProductImage(
    filePath,
    bytes: bytes,
    fileName: fileName,
  );
  static Future<ApiResult> createProduct(Map<String, dynamic> data) =>
      AdminProductApiService.createProduct(data);
  static Future<ApiResult> getProductDetail(String id) =>
      AdminProductApiService.getProductDetail(id);
  static Future<ApiResult> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) => AdminProductApiService.updateProduct(id, data);
  static Future<ApiResult> deleteProduct(String id) =>
      AdminProductApiService.deleteProduct(id);

  static Future<ApiResult> getCart() => CartApiService.getCart();
  static Future<ApiResult> addToCart({
    required String variantId,
    required int quantity,
  }) => CartApiService.addToCart(variantId: variantId, quantity: quantity);
  static Future<ApiResult> updateCartItem({
    required String itemId,
    required int quantity,
  }) => CartApiService.updateCartItem(itemId: itemId, quantity: quantity);
  static Future<ApiResult> deleteCartItem({required String itemId}) =>
      CartApiService.deleteCartItem(itemId: itemId);
  static Future<ApiResult> clearCart() => CartApiService.clearCart();

  static Future<ApiResult> createOrder({
    required String addressId,
    required String paymentMethod,
    String? note,
    String? voucherId,
    int? shippingFee,
    double? deliveryLatitude,
    double? deliveryLongitude,
    double? deliveryDistanceKm,
  }) => OrderApiService.createOrder(
    addressId: addressId,
    paymentMethod: paymentMethod,
    note: note,
    voucherId: voucherId,
    shippingFee: shippingFee,
    deliveryLatitude: deliveryLatitude,
    deliveryLongitude: deliveryLongitude,
    deliveryDistanceKm: deliveryDistanceKm,
  );
  static Future<ApiResult> createStripeCheckoutSession(String orderId) =>
      OrderApiService.createStripeCheckoutSession(orderId);
  static Future<ApiResult> getMyOrders() => OrderApiService.getMyOrders();
  static Future<ApiResult> getAllOrders() => OrderApiService.getAllOrders();
  static Future<ApiResult> getOrderById(String id) =>
      OrderApiService.getOrderById(id);
  static Future<ApiResult> cancelOrder(String id) =>
      OrderApiService.cancelOrder(id);
  static Future<ApiResult> abandonOrder(String id) =>
      OrderApiService.abandonOrder(id);
  static Future<ApiResult> updateOrderStatus(String id, String status) =>
      OrderApiService.updateOrderStatus(id, status);

  static Future<ApiResult> approveCancelOrder(String id) =>
      OrderApiService.approveCancelOrder(id);

  static Future<ApiResult> getNotifications() =>
      NotificationApiService.getNotifications();
  static Future<ApiResult> markNotificationRead(String id) =>
      NotificationApiService.markNotificationRead(id);
  static Future<ApiResult> markAllNotificationsRead() =>
      NotificationApiService.markAllNotificationsRead();
  static Future<ApiResult> deleteNotification(String id) =>
      NotificationApiService.deleteNotification(id);
  static Future<ApiResult> clearNotifications() =>
      NotificationApiService.clearNotifications();

  static Future<ApiResult> getUserProfile(String uid) =>
      UserApiService.getUserProfile(uid);
  static Future<ApiResult> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) => UserApiService.updateUserProfile(uid, data);
  static Future<ApiResult> getAddresses(String uid) =>
      UserApiService.getAddresses(uid);
  static Future<ApiResult> createAddress({
    required String uid,
    required String recipientName,
    required String phone,
    required String street,
    String? ward,
    String? district,
    String? city,
    bool isDefault = false,
  }) => UserApiService.createAddress(
    uid: uid,
    recipientName: recipientName,
    phone: phone,
    street: street,
    ward: ward,
    district: district,
    city: city,
    isDefault: isDefault,
  );
  static Future<ApiResult> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) => UserApiService.updateAddress(addressId, data);
  static Future<ApiResult> deleteAddress(String addressId) =>
      UserApiService.deleteAddress(addressId);

  static Future<ApiResult> getMessages() => ChatApiService.getMessages();
  static Future<ApiResult> sendMessage(String content) =>
      ChatApiService.sendMessage(content);
  static Future<ApiResult> getChatSessions() =>
      ChatApiService.getChatSessions();
  static Future<ApiResult> getMessagesForAdmin(String uid) =>
      ChatApiService.getMessagesForAdmin(uid);
  static Future<ApiResult> replyMessage(String uid, String content) =>
      ChatApiService.replyMessage(uid, content);

  static Future<ApiResult> getMyVouchers() => VoucherApiService.getMyVouchers();
  static Future<ApiResult> getAllVouchers() =>
      VoucherApiService.getAllVouchers();
  static Future<ApiResult> createVoucher(Map<String, dynamic> data) =>
      VoucherApiService.createVoucher(data);
  static Future<ApiResult> updateVoucher(
    String id,
    Map<String, dynamic> data,
  ) => VoucherApiService.updateVoucher(id, data);
  static Future<ApiResult> deleteVoucher(String id) =>
      VoucherApiService.deleteVoucher(id);
}
