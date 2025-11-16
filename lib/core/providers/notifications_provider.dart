import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../storage/notifications_local_ds.dart';

/// Provider for notifications local data source
final notificationsLocalDataSourceProvider = Provider<NotificationsLocalDataSource>((ref) {
  return NotificationsLocalDataSource();
});

/// Provider for all notifications
final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final dataSource = ref.watch(notificationsLocalDataSourceProvider);
  return await dataSource.getAllNotifications();
});

/// Provider for unread count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final dataSource = ref.watch(notificationsLocalDataSourceProvider);
  return await dataSource.getUnreadCount();
});

/// Notifier for managing notification actions
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final NotificationsLocalDataSource _dataSource;

  /// Load all notifications
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _dataSource.getAllNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    await _dataSource.markAsRead(id);
    await loadNotifications();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _dataSource.markAllAsRead();
    await loadNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    await _dataSource.deleteNotification(id);
    await loadNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    await _dataSource.clearAll();
    await loadNotifications();
  }
}

/// Provider for notifications notifier
final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  final dataSource = ref.watch(notificationsLocalDataSourceProvider);
  return NotificationsNotifier(dataSource);
});
