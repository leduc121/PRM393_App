import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final notifications = state.visibleNotifications;
    final unreadCount = notifications.where((item) => !item.isRead).length;
    final isEmpty = notifications.isEmpty;
    final groups = _groupNotifications(notifications);

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsHeader(
              unreadCount: unreadCount,
              showUnreadBadge: !isEmpty,
              onMore: () => _showNotificationActions(context, state),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: state.fetchNotifications,
                child: isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height - 120,
                            child: const _EmptyNotificationsView(),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 18),
                        children: [
                          for (final group in groups) ...[
                            _NotificationSectionHeader(title: group.title),
                            for (final item in group.items)
                              _NotificationTile(
                                item: item,
                                onDelete: () => state.deleteNotification(item),
                                onPay: item.isCartReminder
                                    ? () => Navigator.pushNamed(
                                        context,
                                        '/checkout',
                                      )
                                    : null,
                              ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationGroup> _groupNotifications(List<NotificationItem> items) {
    final today = <NotificationItem>[];
    final yesterday = <NotificationItem>[];
    final older = <NotificationItem>[];
    final now = DateTime.now();

    for (final item in items) {
      final createdAt = item.createdAt ?? now;
      if (_isSameDay(createdAt, now)) {
        today.add(item);
      } else if (_isSameDay(createdAt, now.subtract(const Duration(days: 1)))) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }

    return [
      if (today.isNotEmpty) _NotificationGroup('Today', today),
      if (yesterday.isNotEmpty) _NotificationGroup('Yesterday', yesterday),
      if (older.isNotEmpty) _NotificationGroup('This Weekend', older),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final left = a.toLocal();
    final right = b.toLocal();
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  void _showNotificationActions(BuildContext context, SportZoneState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: SportZoneTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NotificationSheetAction(
                  label: 'Clear All',
                  color: SportZoneTheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    state.clearAllNotifications();
                  },
                ),
                const Divider(height: 1, color: SportZoneTheme.borderSubtle),
                _NotificationSheetAction(
                  label: 'Mark all as read',
                  color: SportZoneTheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    state.markAllNotificationsRead();
                  },
                ),
                const Divider(height: 8, color: SportZoneTheme.borderSubtle),
                _NotificationSheetAction(
                  label: 'Cancel',
                  color: SportZoneTheme.primary,
                  fontSize: 20,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final bool showUnreadBadge;
  final VoidCallback onMore;

  const _NotificationsHeader({
    required this.unreadCount,
    required this.showUnreadBadge,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: SportZoneTheme.primary,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showUnreadBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SportZoneTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount Má»šI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SportZoneTheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: SportZoneTheme.primary,
                ),
                onPressed: onMore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationGroup {
  final String title;
  final List<NotificationItem> items;

  const _NotificationGroup(this.title, this.items);
}

class _NotificationSectionHeader extends StatelessWidget {
  final String title;

  const _NotificationSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: SportZoneTheme.secondary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NotificationSheetAction extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;
  final VoidCallback onTap;

  const _NotificationSheetAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/notification_empty.png',
              width: 132,
              height: 132,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: SportZoneTheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your notifications will appear here once you've received them.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SportZoneTheme.secondary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Missing notifications?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SportZoneTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Go to historical notifications.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2C7C99),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onDelete;
  final VoidCallback? onPay;

  const _NotificationTile({
    required this.item,
    required this.onDelete,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id ?? '${item.title}-${item.timeAgo}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.only(right: 24),
        color: SportZoneTheme.error,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: item.isRead ? SportZoneTheme.surface : const Color(0xFFEAF1FF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isRead
                    ? SportZoneTheme.surfaceVariant
                    : const Color(0xFFD8E5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(item.category),
                color: SportZoneTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SportZoneTheme.primary,
                        height: 1.35,
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text: item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: ' ${item.content}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SportZoneTheme.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (onPay != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(
                    item.actionLabel ?? 'Pay',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'PAYMENT' => Icons.payments_outlined,
      'ORDER' => Icons.receipt_long,
      'DELIVERY' => Icons.local_shipping,
      'PROMO' => Icons.local_offer,
      'CART' => Icons.shopping_bag_outlined,
      _ => Icons.notifications_outlined,
    };
  }
}
