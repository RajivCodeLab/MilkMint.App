import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import '../../models/delivery/delivery_log.dart';

/// Offline queue manager for syncing pending actions
class OfflineQueueManager {
  static final OfflineQueueManager _instance = OfflineQueueManager._internal();
  
  factory OfflineQueueManager() => _instance;
  
  OfflineQueueManager._internal();

  /// Add action to queue
  static Future<void> queueAction({
    required String actionType,
    required Map<String, dynamic> data,
    String? entityId,
  }) async {
    try {
      final box = await HiveService.getPendingActionsBox();

      final action = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'actionType': actionType,
        'data': data,
        'entityId': entityId,
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
      };

      await box.add(json.encode(action));
      debugPrint('Action queued: $actionType');
    } catch (e) {
      debugPrint('Error queuing action: $e');
    }
  }

  /// Get all pending actions
  static Future<List<Map<String, dynamic>>> getPendingActions() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      final actions = <Map<String, dynamic>>[];

      for (var i = 0; i < box.length; i++) {
        final actionStr = box.getAt(i) as String;
        final action = json.decode(actionStr) as Map<String, dynamic>;
        actions.add(action);
      }

      return actions;
    } catch (e) {
      debugPrint('Error getting pending actions: $e');
      return [];
    }
  }

  /// Remove action from queue
  static Future<void> removeAction(int index) async {
    try {
      final box = await HiveService.getPendingActionsBox();
      await box.deleteAt(index);
      debugPrint('Action removed from queue at index $index');
    } catch (e) {
      debugPrint('Error removing action: $e');
    }
  }

  /// Clear all pending actions
  static Future<void> clearQueue() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      await box.clear();
      debugPrint('Pending actions queue cleared');
    } catch (e) {
      debugPrint('Error clearing queue: $e');
    }
  }

  /// Get queue count
  static Future<int> getQueueCount() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      return box.length;
    } catch (e) {
      debugPrint('Error getting queue count: $e');
      return 0;
    }
  }

  /// Action types for queue
  static const String actionTypeDelivery = 'delivery';
  static const String actionTypePayment = 'payment';
  static const String actionTypeCustomer = 'customer';
  static const String actionTypeHoliday = 'holiday';

  // Delivery Log specific methods
  
  /// Queue a delivery log for syncing
  Future<void> queueDeliveryLog(DeliveryLog log) async {
    try {
      final box = await HiveService.getPendingActionsBox();
      
      final action = {
        'id': log.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'actionType': actionTypeDelivery,
        'data': log.toJson(),
        'entityId': log.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
      };

      await box.add(json.encode(action));
      debugPrint('Delivery log queued: ${log.id}');
    } catch (e) {
      debugPrint('Error queuing delivery log: $e');
      rethrow;
    }
  }

  /// Get all pending delivery logs
  Future<List<DeliveryLog>> getPendingDeliveryLogs() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      final deliveryLogs = <DeliveryLog>[];

      for (var i = 0; i < box.length; i++) {
        final actionStr = box.getAt(i) as String;
        final action = json.decode(actionStr) as Map<String, dynamic>;
        
        if (action['actionType'] == actionTypeDelivery) {
          final logData = action['data'] as Map<String, dynamic>;
          deliveryLogs.add(DeliveryLog.fromJson(logData));
        }
      }

      return deliveryLogs;
    } catch (e) {
      debugPrint('Error getting pending delivery logs: $e');
      return [];
    }
  }

  /// Mark a delivery log as synced (remove from queue)
  Future<void> markLogAsSynced(String logId) async {
    try {
      final box = await HiveService.getPendingActionsBox();
      
      for (var i = box.length - 1; i >= 0; i--) {
        final actionStr = box.getAt(i) as String;
        final action = json.decode(actionStr) as Map<String, dynamic>;
        
        if (action['actionType'] == actionTypeDelivery &&
            action['id'] == logId) {
          await box.deleteAt(i);
          debugPrint('Delivery log marked as synced: $logId');
          break;
        }
      }
    } catch (e) {
      debugPrint('Error marking log as synced: $e');
    }
  }
}
