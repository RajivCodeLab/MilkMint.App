import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/customer/application/customer_home_provider.dart';
import '../../features/customer/application/delivery_history_provider.dart';
import '../../features/vendor/application/billing_provider.dart';
import '../providers/notifications_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/notification_item.dart';
import '../storage/notifications_local_ds.dart';

part 'notification_service.freezed.dart';

/// Notification payload for navigation
@freezed
class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required String type,
    String? route,
    Map<String, dynamic>? data,
  }) = _NotificationPayload;

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      type: message.data['type'] as String? ?? 'general',
      route: message.data['route'] as String?,
      data: message.data,
    );
  }
}

/// Notification service state
@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    String? fcmToken,
    @Default(false) bool isInitialized,
    @Default(false) bool permissionGranted,
    NotificationPayload? pendingNavigation,
    String? error,
  }) = _NotificationState;
}

/// Notification service for managing FCM notifications
class NotificationService {
  NotificationService({
    required FirebaseMessaging messaging,
    required NotificationsLocalDataSource notificationsLocalDataSource,
  }) : _messaging = messaging,
       _notificationsLocalDataSource = notificationsLocalDataSource;

  final FirebaseMessaging _messaging;
  final NotificationsLocalDataSource _notificationsLocalDataSource;

  final _stateController = StreamController<NotificationState>.broadcast();
  Stream<NotificationState> get stateStream => _stateController.stream;

  final _navigationController = StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get navigationStream => _navigationController.stream;

  NotificationState _state = const NotificationState();
  NotificationState get state => _state;

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the notification service
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _navigatorKey = navigatorKey;

    try {
      // Request notification permissions
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ Notification permission granted');

        // Get FCM token
        final token = await _getFCMToken();

        // Register token with backend
        if (token != null) {
          await _registerTokenWithBackend(token);
        }

        // Setup message handlers
        _setupMessageHandlers();

        // Listen for token refresh
        _setupTokenRefreshListener();

        _updateState(_state.copyWith(
          isInitialized: true,
          permissionGranted: true,
          fcmToken: token,
        ));
      } else {
        debugPrint('❌ Notification permission denied');
        _updateState(_state.copyWith(
          isInitialized: true,
          permissionGranted: false,
        ));
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _updateState(_state.copyWith(
        error: e.toString(),
        isInitialized: true,
      ));
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('📱 FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      // TODO: Replace with actual backend endpoint
      debugPrint('Registering FCM token with backend...');
      
      // Example API call:
      // await _apiClient.post('/users/fcm-token', data: {'token': token});
      
      // For now, just log it
      debugPrint('✅ FCM Token would be registered: $token');
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
      // Don't throw - token registration failure shouldn't block app
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state
    _checkInitialMessage();
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      
      _updateState(_state.copyWith(fcmToken: newToken));
      
      // Register new token with backend
      await _registerTokenWithBackend(newToken);
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📩 Foreground message received');
    debugPrint('  Title: ${message.notification?.title}');
    debugPrint('  Body: ${message.notification?.body}');
    debugPrint('  Data: ${message.data}');

    // Save notification to local storage
    _saveNotificationToLocal(message);

    // Show local notification or in-app notification
    _showInAppNotification(message);

    // If there's a navigation payload, emit it
    if (message.data.isNotEmpty) {
      final payload = NotificationPayload.fromRemoteMessage(message);
      _navigationController.add(payload);
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped');
    debugPrint('  Data: ${message.data}');

    // Save notification to local storage
    _saveNotificationToLocal(message);

    final payload = NotificationPayload.fromRemoteMessage(message);
    _navigateToScreen(payload);
  }

  /// Save notification to local storage
  Future<void> _saveNotificationToLocal(RemoteMessage message) async {
    try {
      final notificationItem = NotificationItem.fromRemoteMessage(
        messageId: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
      );
      await _notificationsLocalDataSource.saveNotification(notificationItem);
      debugPrint('💾 Notification saved to local storage');
    } catch (e) {
      debugPrint('⚠️ Error saving notification to local storage: $e');
    }
  }

  /// Check for initial message (app opened from terminated state)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('🚀 App opened from terminated state via notification');
      debugPrint('  Data: ${initialMessage.data}');

      final payload = NotificationPayload.fromRemoteMessage(initialMessage);
      
      // Store for later navigation (after app is ready)
      _updateState(_state.copyWith(pendingNavigation: payload));
    }
  }

  /// Show in-app notification (for foreground messages)
  void _showInAppNotification(RemoteMessage message) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    final notification = message.notification;
    if (notification == null) return;

    // Show SnackBar with notification content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (notification.body != null) ...[
              const SizedBox(height: 4),
              Text(notification.body!),
            ],
          ],
        ),
        backgroundColor: Colors.blue.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            final payload = NotificationPayload.fromRemoteMessage(message);
            _navigateToScreen(payload);
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Navigate to screen based on notification payload
  void _navigateToScreen(NotificationPayload payload) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('⚠️ Navigator context not available, storing for later');
      _updateState(_state.copyWith(pendingNavigation: payload));
      return;
    }

    debugPrint('🧭 Navigating based on payload: ${payload.type}');

    // Route based on notification type
    switch (payload.type) {
      case 'invoice':
        // Navigate to billing screen
        final route = payload.route ?? '/billing';
        Navigator.pushNamed(context, route, arguments: payload.data);
        break;

      case 'payment':
        // Navigate to payments screen
        final route = payload.route ?? '/payments';
        Navigator.pushNamed(context, route, arguments: payload.data);
        break;

      case 'delivery':
        // Navigate to delivery log screen
        final route = payload.route ?? '/delivery-log';
        Navigator.pushNamed(context, route, arguments: payload.data);
        break;

      case 'holiday':
        // Navigate to holiday request screen
        final route = payload.route ?? '/holiday-request';
        Navigator.pushNamed(context, route, arguments: payload.data);
        break;

      case 'customer':
        // Navigate to customer details
        final customerId = payload.data?['customerId'];
        if (customerId != null) {
          Navigator.pushNamed(
            context,
            '/edit-customer',
            arguments: {'customerId': customerId},
          );
        }
        break;

      case 'general':
      default:
        // Navigate to home based on user role
        final route = payload.route ?? '/';
        Navigator.pushNamed(context, route);
        break;
    }

    // Clear pending navigation after successful navigation
    _updateState(_state.copyWith(pendingNavigation: null));
  }

  /// Handle pending navigation (call this after app is ready)
  void handlePendingNavigation() {
    if (_state.pendingNavigation != null) {
      debugPrint('🔄 Handling pending navigation');
      _navigateToScreen(_state.pendingNavigation!);
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe to user-specific topics based on role and vendor
  Future<void> subscribeToUserTopics({
    required String userId,
    required String role,
    String? vendorId,
  }) async {
    // Subscribe to user-specific topic
    await subscribeToTopic('user_$userId');

    // Subscribe to role-specific topics
    switch (role.toLowerCase()) {
      case 'vendor':
        await subscribeToTopic('vendors');
        if (vendorId != null) {
          await subscribeToTopic('vendor_$vendorId');
        }
        break;
      case 'customer':
        await subscribeToTopic('customers');
        if (vendorId != null) {
          await subscribeToTopic('vendor_${vendorId}_customers');
        }
        break;
      case 'delivery_agent':
        await subscribeToTopic('delivery_agents');
        if (vendorId != null) {
          await subscribeToTopic('vendor_${vendorId}_agents');
        }
        break;
    }

    debugPrint('✅ Subscribed to user topics for role: $role');
  }

  /// Unsubscribe from all user topics (for logout)
  Future<void> unsubscribeFromAllTopics({
    required String userId,
    required String role,
    String? vendorId,
  }) async {
    await unsubscribeFromTopic('user_$userId');

    switch (role.toLowerCase()) {
      case 'vendor':
        await unsubscribeFromTopic('vendors');
        if (vendorId != null) {
          await unsubscribeFromTopic('vendor_$vendorId');
        }
        break;
      case 'customer':
        await unsubscribeFromTopic('customers');
        if (vendorId != null) {
          await unsubscribeFromTopic('vendor_${vendorId}_customers');
        }
        break;
      case 'delivery_agent':
        await unsubscribeFromTopic('delivery_agents');
        if (vendorId != null) {
          await unsubscribeFromTopic('vendor_${vendorId}_agents');
        }
        break;
    }

    debugPrint('✅ Unsubscribed from all topics');
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('✅ FCM token deleted');
      
      _updateState(_state.copyWith(
        fcmToken: null,
        pendingNavigation: null,
      ));
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Update state and notify listeners
  void _updateState(NotificationState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
    _navigationController.close();
  }
}

/// Top-level background message handler (required by Firebase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 Background message received');
  debugPrint('  Title: ${message.notification?.title}');
  debugPrint('  Body: ${message.notification?.body}');
  debugPrint('  Data: ${message.data}');
  
  // Handle background notification
  // Note: Cannot show UI here, only process data
}

/// Provider for FirebaseMessaging instance
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final messaging = ref.watch(firebaseMessagingProvider);
  final notificationsLocalDataSource = NotificationsLocalDataSource();

  final service = NotificationService(
    messaging: messaging,
    notificationsLocalDataSource: notificationsLocalDataSource,
  );

  // Listen for navigation/payload events and invalidate relevant providers
  // so UI refreshes when notifications (invoice/holiday/delivery/etc.) arrive.
  service.navigationStream.listen((payload) {
    try {
      switch (payload.type) {
        case 'invoice':
          ref.invalidate(billingProvider);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          break;
        case 'holiday':
          ref.invalidate(customerHomeProvider);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          break;
        case 'delivery':
          ref.invalidate(deliveryHistoryProvider);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          break;
        case 'customer':
          ref.invalidate(customerHomeProvider);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          break;
        default:
          // General notification: refresh notifications list & unread count
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationsCountProvider);
      }
    } catch (_) {
      // Swallow errors to avoid crashing notification listeners
    }
  });

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for notification state stream
final notificationStateProvider = StreamProvider<NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.stateStream;
});

/// Provider for notification navigation stream
final notificationNavigationProvider = StreamProvider<NotificationPayload>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.navigationStream;
});

/// Provider for current FCM token
final fcmTokenProvider = Provider<String?>((ref) {
  final notificationState = ref.watch(notificationStateProvider);
  return notificationState.when(
    data: (state) => state.fcmToken,
    loading: () => null,
    error: (_, __) => null,
  );
});
