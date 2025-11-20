import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../../data/data_sources/remote/notification_remote_ds.dart';
import '../api/api_client.dart';

/// Provider for notification remote data source
final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRemoteDataSource(apiClient);
});

/// Provider for all notifications (now from backend)
/// Uses autoDispose with keepAlive to cache and prevent loops
final notificationsProvider = FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  // Keep provider alive for 5 minutes after last listener
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    link.close();
  });
  
  final dataSource = ref.watch(notificationRemoteDataSourceProvider);
  try {
    final response = await dataSource.getNotifications(page: 1, limit: 100);
    final List<dynamic> notifications = response['notifications'] ?? [];
    return notifications.map((json) => NotificationItem.fromJson(json)).toList();
  } catch (e) {
    // Return empty list on auth errors to prevent loops
    if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      return [];
    }
    rethrow;
  }
});

/// Provider for unread count (now from backend)
/// Uses autoDispose with keepAlive to cache and prevent loops
final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  // Keep provider alive for 1 minute after last listener to prevent constant rebuilds
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 1), () {
    link.close();
  });
  
  final dataSource = ref.watch(notificationRemoteDataSourceProvider);
  try {
    return await dataSource.getUnreadCount();
  } catch (e) {
    // Return 0 on auth errors to prevent loops
    if (e.toString().contains('401') || e.toString().contains('Unauthorized') || e.toString().contains('Session expired')) {
      return 0;
    }
    rethrow;
  }
});

/// Notifier for managing notification actions (now with backend API)
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsNotifier(this._dataSource, this._ref) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final NotificationRemoteDataSource _dataSource;
  final Ref _ref;

  /// Load all notifications from backend
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dataSource.getNotifications(page: 1, limit: 100);
      final List<dynamic> notifications = response['notifications'] ?? [];
      final items = notifications.map((json) => _parseNotification(json)).toList();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Parse notification JSON to NotificationItem
  NotificationItem _parseNotification(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    await _dataSource.markAsRead(id);
    // Refresh unread count
    _ref.invalidate(unreadNotificationsCountProvider);
    await loadNotifications();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _dataSource.markAllAsRead();
    // Refresh unread count
    _ref.invalidate(unreadNotificationsCountProvider);
    await loadNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    await _dataSource.deleteNotification(id);
    // Refresh unread count
    _ref.invalidate(unreadNotificationsCountProvider);
    await loadNotifications();
  }
}

/// Provider for notifications notifier (now using backend API)
final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  final dataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationsNotifier(dataSource, ref);
});
