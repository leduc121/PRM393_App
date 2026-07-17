part of '../sport_zone_state.dart';

extension NotificationStateActions on SportZoneState {
  Future<void> fetchNotifications() async {
    final result = await ApiService.getNotifications();
    if (result.isSuccess && result.data is List) {
      notifications
        ..clear()
        ..addAll(
          (result.data as List).whereType<Map<String, dynamic>>().map(
            NotificationItem.fromJson,
          ),
        );
      notifyStateChanged();
    }
  }

  Future<void> fetchMyVouchers() async {
    final result = await ApiService.getMyVouchers();
    if (result.isSuccess && result.data is List) {
      availableVouchers
        ..clear()
        ..addAll(
          (result.data as List).whereType<Map<String, dynamic>>().map(
            (json) => Voucher.fromJson(json),
          ),
        );
      notifyStateChanged();
    }
  }

  void markAllNotificationsRead() {
    ApiService.markAllNotificationsRead();
    for (var item in notifications) {
      item.isRead = true;
    }
    _cartReminderRead = true;
    notifyStateChanged();
  }

  void clearAllNotifications() {
    ApiService.clearNotifications();
    notifications.clear();
    _cartReminderDismissed = true;
    _cartReminderRead = true;
    notifyStateChanged();
  }

  void deleteNotification(NotificationItem item) {
    if (item.isCartReminder) {
      _cartReminderDismissed = true;
      _cartReminderRead = true;
    } else {
      notifications.removeWhere((notification) => notification.id == item.id);
      final id = item.id;
      if (id != null && id.isNotEmpty) {
        ApiService.deleteNotification(id);
      }
    }
    notifyStateChanged();
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyStateChanged();
  }
}
