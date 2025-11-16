import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/delivery/delivery_log.dart';
import '../api/api_client.dart';
import 'hive_service.dart';

part 'offline_sync_service.freezed.dart';

/// Sync status for tracking
@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(false) bool isSyncing,
    @Default(0) int pendingCount,
    @Default(0) int syncedCount,
    @Default(0) int failedCount,
    DateTime? lastSyncTime,
    String? error,
  }) = _SyncStatus;
}

/// Offline sync service for managing delivery logs and other data
class OfflineSyncService {
  OfflineSyncService({
    required ApiClient apiClient,
    required Connectivity connectivity,
  })  : _apiClient = apiClient,
        _connectivity = connectivity {
    _initialize();
  }

  final ApiClient _apiClient;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = const SyncStatus();
  SyncStatus get currentStatus => _currentStatus;

  bool _isInitialized = false;
  bool _isSyncing = false;

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 30);
  static const Duration autoSyncInterval = Duration(minutes: 5);

  /// Initialize the sync service
  void _initialize() {
    if (_isInitialized) return;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _onConnectivityChanged(results);
      },
    );

    // Start periodic auto-sync
    _startAutoSync();

    _isInitialized = true;
    debugPrint('OfflineSyncService initialized');
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final isConnected = !results.contains(ConnectivityResult.none);

    if (isConnected) {
      debugPrint('Connection restored, starting sync...');
      await syncAll();
    } else {
      debugPrint('Connection lost');
    }
  }

  /// Start automatic sync timer
  void _startAutoSync() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(autoSyncInterval, (_) async {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected && !_isSyncing) {
        debugPrint('Auto-sync triggered');
        await syncAll();
      }
    });
  }

  /// Queue a delivery log for offline sync
  Future<void> queueDeliveryLog(DeliveryLog log) async {
    try {
      final box = await HiveService.getPendingActionsBox();

      // Create a unique ID if not present
      final logId = log.id ?? 
          'temp_${DateTime.now().millisecondsSinceEpoch}_${log.customerId}';

      final action = {
        'id': logId,
        'actionType': 'delivery_log',
        'data': log.copyWith(id: logId, synced: false).toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
        'lastRetryAt': null,
      };

      await box.add(json.encode(action));
      
      // Update status
      _updateSyncStatus();

      debugPrint('Delivery log queued: $logId');

      // Try to sync immediately if connected
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      if (isConnected) {
        await syncDeliveryLogs();
      }
    } catch (e) {
      debugPrint('Error queuing delivery log: $e');
      rethrow;
    }
  }

  /// Sync all delivery logs
  Future<void> syncDeliveryLogs() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    _updateSyncStatus(isSyncing: true);

    try {
      final box = await HiveService.getPendingActionsBox();
      final pendingActions = <Map<String, dynamic>>[];
      final indicesToRemove = <int>[];

      // Collect all delivery log actions
      for (var i = 0; i < box.length; i++) {
        final actionStr = box.getAt(i) as String;
        final action = json.decode(actionStr) as Map<String, dynamic>;

        if (action['actionType'] == 'delivery_log') {
          pendingActions.add({...action, 'index': i});
        }
      }

      if (pendingActions.isEmpty) {
        debugPrint('No pending delivery logs to sync');
        _isSyncing = false;
        _updateSyncStatus(isSyncing: false);
        return;
      }

      debugPrint('Syncing ${pendingActions.length} delivery logs...');

      // Try batch sync first if multiple logs
      if (pendingActions.length > 1) {
        final batchResult = await _syncDeliveryLogsBatch(pendingActions);
        if (batchResult != null) {
          // Batch sync succeeded
          for (final index in batchResult.syncedIndices) {
            await box.deleteAt(index);
          }
          
          _updateSyncStatus(
            isSyncing: false,
            syncedCount: batchResult.syncedCount,
            failedCount: batchResult.failedCount,
            lastSyncTime: DateTime.now(),
          );
          _isSyncing = false;
          return;
        }
        // If batch fails, fall back to individual sync
        debugPrint('Batch sync failed, falling back to individual sync');
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Sync each action
      for (final action in pendingActions) {
        try {
          final logData = action['data'] as Map<String, dynamic>;
          final deliveryLog = DeliveryLog.fromJson(logData);
          final retryCount = action['retryCount'] as int;

          // Check if retry limit exceeded
          if (retryCount >= maxRetryAttempts) {
            debugPrint('Max retry attempts exceeded for log: ${action['id']}');
            failedCount++;
            continue;
          }

          // Attempt to sync to backend
          final success = await _syncDeliveryLogToBackend(deliveryLog);

          if (success) {
            // Mark for removal from queue
            indicesToRemove.add(action['index'] as int);
            syncedCount++;
            debugPrint('Successfully synced log: ${action['id']}');
          } else {
            // Increment retry count
            await _incrementRetryCount(box, action['index'] as int, action);
            failedCount++;
          }
        } catch (e) {
          debugPrint('Error syncing action: $e');
          await _incrementRetryCount(box, action['index'] as int, action);
          failedCount++;
        }
      }

      // Remove synced items (in reverse order to maintain indices)
      indicesToRemove.sort((a, b) => b.compareTo(a));
      for (final index in indicesToRemove) {
        await box.deleteAt(index);
      }

      debugPrint('Sync complete: $syncedCount synced, $failedCount failed');

      _updateSyncStatus(
        isSyncing: false,
        syncedCount: syncedCount,
        failedCount: failedCount,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error during sync: $e');
      _updateSyncStatus(
        isSyncing: false,
        error: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Batch sync delivery logs to backend
  Future<({int syncedCount, int failedCount, List<int> syncedIndices})?> _syncDeliveryLogsBatch(
    List<Map<String, dynamic>> pendingActions,
  ) async {
    try {
      final logs = pendingActions.map((action) {
        final logData = action['data'] as Map<String, dynamic>;
        final log = DeliveryLog.fromJson(logData);
        // Send only fields backend expects
        return {
          'customerId': log.customerId,
          'date': log.date.toIso8601String().split('T')[0],
          'delivered': log.delivered,
          'quantityDelivered': log.quantityDelivered,
        };
      }).toList();

      final response = await _apiClient.post(
        '/delivery-logs/batch',
        data: {'logs': logs},
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final successCount = data['success'] as int? ?? 0;
        final failedCount = data['failed'] as int? ?? 0;
        
        // Mark all as synced if batch succeeded
        final syncedIndices = List<int>.generate(
          pendingActions.length,
          (index) => pendingActions[index]['index'] as int,
        );
        
        debugPrint('Batch sync completed: $successCount synced, $failedCount failed');
        
        return (
          syncedCount: successCount,
          failedCount: failedCount,
          syncedIndices: syncedIndices,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Batch sync error: $e');
      return null;
    }
  }

  /// Sync delivery log to backend with conflict resolution
  Future<bool> _syncDeliveryLogToBackend(DeliveryLog log) async {
    try {
      // POST to backend - send only the fields backend expects
      final response = await _apiClient.post(
        '/delivery-logs',
        data: {
          'customerId': log.customerId,
          'date': log.date.toIso8601String().split('T')[0],
          'delivered': log.delivered,
          'quantityDelivered': log.quantityDelivered,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      // Handle conflict (409) - merge by timestamp
      if (response.statusCode == 409) {
        debugPrint('Conflict detected for log: ${log.id}, resolving...');
        return await _resolveConflict(log, response.data);
      }

      return false;
    } on ApiException catch (e) {
      // Handle specific API errors
      if (e.type == ApiExceptionType.noInternet) {
        debugPrint('No internet connection, will retry later');
        return false;
      }

      // For server errors, retry
      if (e.type == ApiExceptionType.serverError ||
          e.type == ApiExceptionType.timeout) {
        debugPrint('Server error, will retry: ${e.message}');
        return false;
      }

      // For client errors (400, 404), don't retry
      if (e.type == ApiExceptionType.badRequest ||
          e.type == ApiExceptionType.notFound) {
        debugPrint('Client error, removing from queue: ${e.message}');
        return true; // Remove from queue
      }

      return false;
    } catch (e) {
      debugPrint('Unexpected error syncing log: $e');
      return false;
    }
  }

  /// Resolve conflicts using timestamp-based merge
  Future<bool> _resolveConflict(
    DeliveryLog localLog,
    dynamic serverResponse,
  ) async {
    try {
      // Get server version
      final serverLog = DeliveryLog.fromJson(
        serverResponse['data'] as Map<String, dynamic>,
      );

      // Compare timestamps - newer wins
      final localTime = localLog.timestamp;
      final serverTime = serverLog.timestamp;

      if (localTime.isAfter(serverTime)) {
        // Local is newer, force update
        debugPrint('Local log is newer, forcing update...');
        final response = await _apiClient.put(
          '/delivery-logs/${localLog.id}',
          data: {
            ...localLog.toJson(),
            'forceUpdate': true,
            'conflictResolution': 'timestamp',
          },
        );

        return response.statusCode == 200;
      } else {
        // Server is newer or same, accept server version
        debugPrint('Server log is newer, accepting server version');
        return true; // Remove from queue
      }
    } catch (e) {
      debugPrint('Error resolving conflict: $e');
      return false;
    }
  }

  /// Increment retry count for failed sync
  Future<void> _incrementRetryCount(
    box,
    int index,
    Map<String, dynamic> action,
  ) async {
    try {
      final updatedAction = {
        ...action,
        'retryCount': (action['retryCount'] as int) + 1,
        'lastRetryAt': DateTime.now().toIso8601String(),
      };

      await box.putAt(index, json.encode(updatedAction));
      debugPrint('Incremented retry count for action: ${action['id']}');
    } catch (e) {
      debugPrint('Error incrementing retry count: $e');
    }
  }

  /// Sync all pending actions
  Future<void> syncAll() async {
    await syncDeliveryLogs();
    // Add other sync methods here (payments, holidays, etc.)
  }

  /// Get pending delivery logs
  Future<List<DeliveryLog>> getPendingDeliveryLogs() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      final logs = <DeliveryLog>[];

      for (var i = 0; i < box.length; i++) {
        final actionStr = box.getAt(i) as String;
        final action = json.decode(actionStr) as Map<String, dynamic>;

        if (action['actionType'] == 'delivery_log') {
          final logData = action['data'] as Map<String, dynamic>;
          logs.add(DeliveryLog.fromJson(logData));
        }
      }

      return logs;
    } catch (e) {
      debugPrint('Error getting pending delivery logs: $e');
      return [];
    }
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      return box.length;
    } catch (e) {
      debugPrint('Error getting pending count: $e');
      return 0;
    }
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus({
    bool? isSyncing,
    int? syncedCount,
    int? failedCount,
    DateTime? lastSyncTime,
    String? error,
  }) async {
    final pendingCount = await getPendingCount();

    _currentStatus = _currentStatus.copyWith(
      isSyncing: isSyncing ?? _currentStatus.isSyncing,
      pendingCount: pendingCount,
      syncedCount: syncedCount ?? _currentStatus.syncedCount,
      failedCount: failedCount ?? _currentStatus.failedCount,
      lastSyncTime: lastSyncTime ?? _currentStatus.lastSyncTime,
      error: error,
    );

    _syncStatusController.add(_currentStatus);
  }

  /// Clear all pending actions (use with caution)
  Future<void> clearQueue() async {
    try {
      final box = await HiveService.getPendingActionsBox();
      await box.clear();
      debugPrint('Sync queue cleared');
      _updateSyncStatus();
    } catch (e) {
      debugPrint('Error clearing queue: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _syncStatusController.close();
    debugPrint('OfflineSyncService disposed');
  }
}

/// Provider for OfflineSyncService
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final connectivity = Connectivity();

  final service = OfflineSyncService(
    apiClient: apiClient,
    connectivity: connectivity,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for sync status stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.syncStatusStream;
});
