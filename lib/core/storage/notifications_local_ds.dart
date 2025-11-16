import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_item.dart';

/// Local data source for notification history
class NotificationsLocalDataSource {
  static const String _boxName = 'notifications';
  Box<NotificationItem>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<NotificationItem>(_boxName);
    }
  }

  /// Save notification
  Future<void> saveNotification(NotificationItem notification) async {
    await init();
    await _box!.put(notification.id, notification);
  }

  /// Get all notifications (sorted by timestamp descending)
  Future<List<NotificationItem>> getAllNotifications() async {
    await init();
    final notifications = _box!.values.toList();
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    await init();
    return _box!.values.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    await init();
    final notification = _box!.get(id);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await init();
    for (final notification in _box!.values) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    await init();
    await _box!.delete(id);
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Get notification by ID
  Future<NotificationItem?> getNotification(String id) async {
    await init();
    return _box!.get(id);
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
  }
}
