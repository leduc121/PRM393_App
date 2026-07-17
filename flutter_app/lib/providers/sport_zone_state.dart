import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';

part 'state_actions/auth_state_actions.dart';
part 'state_actions/product_state_actions.dart';
part 'state_actions/cart_state_actions.dart';
part 'state_actions/notification_state_actions.dart';
part 'state_actions/chat_state_actions.dart';

class SportZoneState extends ChangeNotifier {
  User? currentUser;
  String selectedCategory = 'Táº¥t cáº£';
  String? selectedCategoryId;
  String selectedBrand = 'Táº¥t cáº£';
  String? selectedBrandId;
  bool isBotTyping = false;
  int selectedTabIndex = 0;

  int? filterMinPrice;
  int? filterMaxPrice;
  String? filterGender;
  String? filterSize;

  // API-loaded data
  List<Product> apiProducts = [];
  List<Category> apiCategories = [];
  List<Brand> apiBrands = [];
  bool isLoadingProducts = false;
  bool isLoadingAuth = false;
  String? authError;
  String? searchQuery;

  final List<CartItem> cartItems = [];
  final List<NotificationItem> notifications = [];
  final List<Voucher> availableVouchers = [];
  DateTime? _cartUpdatedAt;
  bool _cartReminderDismissed = false;
  bool _cartReminderRead = false;

  final List<ChatMessage> chatMessages = [
    ChatMessage(
      message:
          'ChÃ o báº¡n, nhÃ¢n viÃªn sáº½ há»— trá»£ báº¡n ngay trong giÃ¢y lÃ¡t. Vui lÃ²ng cho biáº¿t size chÃ¢n thÃ´ng thÆ°á»ng cá»§a báº¡n nhÃ©!',
      isUser: false,
    ),
  ];

  void notifyStateChanged() => notifyListeners();

  List<NotificationItem> get visibleNotifications {
    final items = [...notifications];
    if (cartItems.isNotEmpty && !_cartReminderDismissed) {
      items.insert(
        0,
        NotificationItem.cartReminder(
          itemCount: cartItems.fold<int>(0, (sum, item) => sum + item.quantity),
          createdAt: _cartUpdatedAt,
          isRead: _cartReminderRead,
        ),
      );
    }
    items.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.now();
      final bDate = b.createdAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return items;
  }
}
