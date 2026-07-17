part of '../sport_zone_state.dart';

extension AuthStateActions on SportZoneState {
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Auth Methods (API) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  /// Try auto-login using saved token
  Future<bool> tryAutoLogin() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    final result = await ApiService.getMe();
    if (result.isSuccess && result.data != null) {
      currentUser = User.fromJson(result.data as Map<String, dynamic>);
      await fetchCart();
      await fetchNotifications();
      notifyStateChanged();
      return true;
    } else {
      await ApiService.clearToken();
      return false;
    }
  }

  /// Login via API
  Future<String?> loginAsync(String email, String password) async {
    isLoadingAuth = true;
    authError = null;
    notifyStateChanged();

    final result = await ApiService.login(email: email, password: password);

    isLoadingAuth = false;

    if (result.isSuccess) {
      final data = result.data as Map<String, dynamic>;
      if (data['user'] != null) {
        currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      }
      await fetchCart();
      await fetchNotifications();
      notifyStateChanged();
      return null; // no error
    } else {
      authError = result.errorMessage;
      notifyStateChanged();
      return result.errorMessage;
    }
  }

  /// Register via API
  Future<String?> registerAsync({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    isLoadingAuth = true;
    authError = null;
    notifyStateChanged();

    final result = await ApiService.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );

    isLoadingAuth = false;

    if (result.isSuccess) {
      notifyStateChanged();
      return null;
    } else {
      authError = result.errorMessage;
      notifyStateChanged();
      return result.errorMessage;
    }
  }

  Future<void> logoutAsync() async {
    await ApiService.logout();
    currentUser = null;
    apiProducts.clear();
    notifications.clear();
    _cartReminderDismissed = false;
    _cartReminderRead = false;
    selectedTabIndex = 0;
    notifyStateChanged();
  }

  Future<String?> updateProfileAsync({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) return 'Vui lÃƒÂ²ng Ã„â€˜Ã„Æ’ng nhÃ¡ÂºÂ­p lÃ¡ÂºÂ¡i';

    final result = await ApiService.updateUserProfile(user.uid, {
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
    });

    if (!result.isSuccess) {
      return result.errorMessage ??
          'CÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t profile thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i';
    }

    currentUser = User.fromJson(result.data as Map<String, dynamic>);
    notifyStateChanged();
    return null;
  }

  Future<String?> verifyOtpAsync(String email, String otp) async {
    isLoadingAuth = true;
    authError = null;
    notifyStateChanged();

    final result = await ApiService.verifyOtp(email: email, otp: otp);

    isLoadingAuth = false;

    if (result.isSuccess) {
      final data = result.data as Map<String, dynamic>;
      if (data['user'] != null) {
        currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      }
      await fetchCart();
      await fetchNotifications();
      notifyStateChanged();
      return null; // success
    } else {
      notifyStateChanged();
      return result.errorMessage ?? 'XÃƒÂ¡c thÃ¡Â»Â±c thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i';
    }
  }

  Future<String?> resendOtpAsync(String email) async {
    isLoadingAuth = true;
    authError = null;
    notifyStateChanged();

    final result = await ApiService.resendOtp(email: email);

    isLoadingAuth = false;
    notifyStateChanged();

    if (result.isSuccess) {
      return null; // success
    } else {
      return result.errorMessage ??
          'GÃ¡Â»Â­i lÃ¡ÂºÂ¡i mÃƒÂ£ thÃ¡ÂºÂ¥t bÃ¡ÂºÂ¡i';
    }
  }

  // Keep legacy methods for backward compat (used nowhere now, but safe)
  bool login(String username, String password) {
    if (username.isNotEmpty && password.length >= 4) {
      currentUser = User(
        uid: '',
        name: username.split('@').first,
        email: username,
        phone: '0900000000',
      );
      notifyStateChanged();
      return true;
    }
    return false;
  }

  bool register(String name, String email, String phone, String password) {
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        password.length >= 4) {
      currentUser = User(uid: '', name: name, email: email, phone: phone);
      notifyStateChanged();
      return true;
    }
    return false;
  }
}
