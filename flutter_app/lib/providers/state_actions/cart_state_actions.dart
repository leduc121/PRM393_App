part of '../sport_zone_state.dart';

extension CartStateActions on SportZoneState {
  void _updateLocalCart(Map<String, dynamic> cartData) {
    final itemsList = cartData['items'] as List<dynamic>? ?? [];
    final hadItems = cartItems.isNotEmpty;
    cartItems.clear();
    cartItems.addAll(
      itemsList.map((json) => CartItem.fromJson(json as Map<String, dynamic>)),
    );
    if (cartItems.isNotEmpty) {
      _cartUpdatedAt = DateTime.now();
      if (!hadItems) {
        _cartReminderDismissed = false;
        _cartReminderRead = false;
      }
    } else {
      _cartUpdatedAt = null;
      _cartReminderDismissed = false;
      _cartReminderRead = false;
    }
    notifyStateChanged();
  }

  Future<void> fetchCart() async {
    final result = await ApiService.getCart();
    if (result.isSuccess && result.data != null) {
      _updateLocalCart(result.data as Map<String, dynamic>);
    }
  }

  Future<String?> addToCart(
    Product product, {
    String? variantId,
    String? size,
    String? color,
    int quantity = 1,
  }) async {
    try {
      String? targetVariantId = variantId;

      if (targetVariantId == null) {
        final detailResult = await ApiService.getProductDetail(product.id);
        if (!detailResult.isSuccess) {
          return detailResult.errorMessage ??
              'KhÃƒÂ´ng thÃ¡Â»Æ’ tÃ¡ÂºÂ£i thÃƒÂ´ng tin sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m';
        }

        final List vList = detailResult.data['variants'] ?? [];
        final variants = vList.map((v) => ProductVariant.fromJson(v)).toList();
        if (variants.isEmpty) {
          return 'SÃ¡ÂºÂ£n phÃ¡ÂºÂ©m hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i khÃƒÂ´ng cÃƒÂ³ sÃ¡ÂºÂµn kÃƒÂ­ch cÃ¡Â»Â¡/mÃƒÂ u sÃ¡ÂºÂ¯c.';
        }

        ProductVariant matched;
        if (size != null && color != null) {
          matched = variants.firstWhere(
            (v) => v.size == size && v.colorName == color,
            orElse: () => variants.first,
          );
        } else {
          matched = variants.first;
        }
        targetVariantId = matched.id;
      }

      final cartResult = await ApiService.addToCart(
        variantId: targetVariantId,
        quantity: quantity,
      );

      if (cartResult.isSuccess) {
        _updateLocalCart(cartResult.data);
        return null;
      } else {
        return cartResult.errorMessage ??
            'KhÃƒÂ´ng thÃ¡Â»Æ’ thÃƒÂªm vÃƒÂ o giÃ¡Â»Â hÃƒÂ ng';
      }
    } catch (e) {
      return 'LÃ¡Â»â€”i: $e';
    }
  }

  Future<String?> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        return deleteCartItem(itemId);
      }
      final result = await ApiService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );
      if (result.isSuccess) {
        _updateLocalCart(result.data);
        return null;
      } else {
        return result.errorMessage ??
            'CÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t giÃ¡Â»Â hÃƒÂ ng thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i';
      }
    } catch (e) {
      return 'LÃ¡Â»â€”i: $e';
    }
  }

  Future<String?> deleteCartItem(String itemId) async {
    try {
      final result = await ApiService.deleteCartItem(itemId: itemId);
      if (result.isSuccess) {
        _updateLocalCart(result.data);
        return null;
      } else {
        return result.errorMessage ??
            'XÃƒÂ³a mÃ¡ÂºÂ·t hÃƒÂ ng thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i';
      }
    } catch (e) {
      return 'LÃ¡Â»â€”i: $e';
    }
  }

  Future<ApiResult> checkout({
    required String recipientName,
    required String phone,
    required String street,
    required String paymentMethod,
    String? note,
    String? voucherId,
    int? shippingFee,
    double? deliveryLatitude,
    double? deliveryLongitude,
    double? deliveryDistanceKm,
  }) async {
    if (currentUser == null) {
      return ApiResult.error(
        'Vui lÃƒÂ²ng Ã„â€˜Ã„Æ’ng nhÃ¡ÂºÂ­p Ã„â€˜Ã¡Â»Æ’ thanh toÃƒÂ¡n',
      );
    }

    try {
      // 1. Get user's addresses
      final addrResult = await ApiService.getAddresses(currentUser!.uid);
      String? addressId;

      if (addrResult.isSuccess && addrResult.data is List) {
        final List list = addrResult.data;
        // Check if there is an exact match
        for (var addr in list) {
          if (addr['recipientName'] == recipientName &&
              addr['phone'] == phone &&
              addr['street'] == street) {
            addressId = addr['addressId']?.toString();
            break;
          }
        }
      }

      // 2. If no matching address, create one
      if (addressId == null) {
        final createAddrResult = await ApiService.createAddress(
          uid: currentUser!.uid,
          recipientName: recipientName,
          phone: phone,
          street: street,
          district: 'QuÃ¡ÂºÂ­n 1', // fallback since simple address text field
          city: 'TP. HÃ¡Â»â€œ ChÃƒÂ­ Minh',
          isDefault: true,
        );
        if (!createAddrResult.isSuccess) {
          return ApiResult.error(
            createAddrResult.errorMessage ??
                'KhÃƒÂ´ng thÃ¡Â»Æ’ tÃ¡ÂºÂ¡o Ã„â€˜Ã¡Â»â€¹a chÃ¡Â»â€° giao hÃƒÂ ng',
          );
        }
        addressId = createAddrResult.data['addressId']?.toString();
      }

      if (addressId == null) {
        return ApiResult.error(
          'LÃ¡Â»â€”i khÃ¡Â»Å¸i tÃ¡ÂºÂ¡o Ã„â€˜Ã¡Â»â€¹a chÃ¡Â»â€° giao hÃƒÂ ng',
        );
      }

      // 3. Create order on backend
      final orderResult = await ApiService.createOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        note: note,
        voucherId: voucherId,
        shippingFee: shippingFee,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        deliveryDistanceKm: deliveryDistanceKm,
      );

      if (orderResult.isSuccess) {
        // Clear local cart items because the backend has cleared it
        cartItems.clear();
        await fetchNotifications();
        // Refresh user data to get updated tier/totalSpent
        final meResult = await ApiService.getMe();
        if (meResult.isSuccess && meResult.data != null) {
          currentUser = User.fromJson(meResult.data as Map<String, dynamic>);
        }

        notifyStateChanged();
        return ApiResult.success(orderResult.data);
      } else {
        return ApiResult.error(
          orderResult.errorMessage ?? 'Ã„ÂÃ¡ÂºÂ·t hÃƒÂ ng thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i',
        );
      }
    } catch (e) {
      return ApiResult.error('LÃ¡Â»â€”i thanh toÃƒÂ¡n: $e');
    }
  }
}
