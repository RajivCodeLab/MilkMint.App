import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../core/offline/offline_sync_service.dart';
import '../../auth/application/auth_provider.dart';
import '../../../models/user_role.dart';
import '../../../data/providers/remote_data_source_providers.dart';

/// Delivery log state
class DeliveryLogState {
  final List<DeliveryLog> logs;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final DateTime selectedDate;
  final int pendingSyncCount;

  DeliveryLogState({
    this.logs = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    DateTime? selectedDate,
    this.pendingSyncCount = 0,
  }) : selectedDate = selectedDate ?? DateTime.now();

  DeliveryLogState copyWith({
    List<DeliveryLog>? logs,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    DateTime? selectedDate,
    int? pendingSyncCount,
  }) {
    return DeliveryLogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }

  List<DeliveryLog> get todayLogs {
    // Use selectedDate instead of always using today
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return logs.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      return logDate.isAtSameMomentAs(selected);
    }).toList();
  }

  int get deliveredCount => todayLogs.where((log) => log.delivered).length;
  int get pendingCount => todayLogs.where((log) => !log.delivered).length;
  double get totalQuantityDelivered => todayLogs
      .where((log) => log.delivered)
      .fold(0.0, (sum, log) => sum + (log.quantityDelivered ?? 0.0));
}

/// Delivery log notifier
class DeliveryLogNotifier extends StateNotifier<DeliveryLogState> {
  final OfflineSyncService _syncService;
  final Ref _ref;

  DeliveryLogNotifier(this._syncService, this._ref)
      : super(DeliveryLogState()) {
    _initSyncListener();
  }

  void _initSyncListener() {
    _syncService.syncStatusStream.listen((syncStatus) async {
      // Update basic sync flags
      state = state.copyWith(
        isSyncing: syncStatus.isSyncing,
        pendingSyncCount: syncStatus.pendingCount,
      );

      // When syncing finishes, reload logs to pick up authoritative server state.
      // This avoids a race where a stale queued log temporarily overrides the
      // server record in the UI.
      if (!syncStatus.isSyncing) {
        try {
          await loadLogs(date: state.selectedDate);
        } catch (_) {
          // Ignore reload errors; state flags already updated above.
        }
      }
    });
  }

  Future<void> loadLogs({DateTime? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final selectedDate = date ?? DateTime.now();
      List<DeliveryLog> apiLogs = [];
      
      // Try to load from API, but don't fail if it's not available
      try {
        final remoteDs = _ref.read(deliveryLogRemoteDataSourceProvider);
        
        // Backend now stores dates correctly at UTC midnight
        // Query for the selected date only (same start and end date)
        final localDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        
        apiLogs = await remoteDs.getLogsByDateRange(
          startDate: localDate,
          endDate: localDate,  // Same date for exact day match
        );
      } catch (apiError) {
        // API not available, continue with offline data only
        debugPrint('API not available, using offline data only: $apiError');
      }
      
      // Load from offline queue - this is the primary source for unsynced logs
      final queuedLogs = await _syncService.getPendingDeliveryLogs();
      
      // Filter queued logs to only include today's logs for the selected date
      final todayQueuedLogs = queuedLogs.where((log) {
        return log.date.year == selectedDate.year &&
            log.date.month == selectedDate.month &&
            log.date.day == selectedDate.day;
      }).toList();
      
      // Merge API logs with queued logs, removing duplicates
      // Prioritize queued logs (they are newer/unsynced changes)
      final allLogsMap = <String, DeliveryLog>{};
      
      // Add API logs first - mark as synced since they came from server
      for (final log in apiLogs) {
        // Use local date for key to avoid timezone issues
        final logLocalDate = DateTime(log.date.year, log.date.month, log.date.day);
        final key = '${log.customerId}_${logLocalDate.toIso8601String().split('T')[0]}';
        allLogsMap[key] = log.copyWith(synced: true);
      }
      
      // Override with queued logs (these are unsynced, keep synced: false)
      for (final log in todayQueuedLogs) {
        final logLocalDate = DateTime(log.date.year, log.date.month, log.date.day);
        final key = '${log.customerId}_${logLocalDate.toIso8601String().split('T')[0]}';
        allLogsMap[key] = log;
      }
      
      state = state.copyWith(
        logs: allLogsMap.values.toList(),
        isLoading: false,
        pendingSyncCount: queuedLogs.length,
        selectedDate: date,
      );
    } catch (e) {
      // Even if there's an error, try to load from offline queue
      try {
        final queuedLogs = await _syncService.getPendingDeliveryLogs();
        final selectedDate = date ?? DateTime.now();
        final todayQueuedLogs = queuedLogs.where((log) {
          return log.date.year == selectedDate.year &&
              log.date.month == selectedDate.month &&
              log.date.day == selectedDate.day;
        }).toList();
        
        state = state.copyWith(
          logs: todayQueuedLogs,
          isLoading: false,
          pendingSyncCount: queuedLogs.length,
          error: 'Using offline data only',
        );
      } catch (offlineError) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load delivery logs: $e',
        );
      }
    }
  }

  Future<void> toggleDelivery({
    required String customerId,
    required String customerName,
    required double quantity,
  }) async {
    try {
      // Use the selected date from state (defaults to today if not set)
      final selectedDate = state.selectedDate;
      final logDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      
      // Determine vendorId from authenticated user (prefer backend id)
      final currentUser = _ref.read(currentUserProvider);
      String vendorId = '';
      if (currentUser != null) {
        if (currentUser.role == UserRole.vendor) {
          vendorId = currentUser.id ?? currentUser.uid;
        } else {
          vendorId = currentUser.vendorId ?? currentUser.id ?? currentUser.uid;
        }
      }

      final existingLog = state.todayLogs.firstWhere(
        (log) => log.customerId == customerId,
        orElse: () => DeliveryLog(
          vendorId: vendorId,
          customerId: customerId,
          date: logDate,
          delivered: false,
          quantityDelivered: 0,
          timestamp: DateTime.now(),
          synced: false,
        ),
      );

      final updatedLog = existingLog.copyWith(
        delivered: !existingLog.delivered,
        quantityDelivered: !existingLog.delivered ? quantity : 0,
        timestamp: DateTime.now(),
        synced: false,
      );

      // Save to offline queue
      await _syncService.queueDeliveryLog(updatedLog);

      // Update state
      final updatedLogs = state.logs.map((log) {
        return log.customerId == customerId ? updatedLog : log;
      }).toList();

      // If it's a new log, add it
      if (!state.logs.any((log) => log.customerId == customerId)) {
        updatedLogs.add(updatedLog);
      }

      state = state.copyWith(
        logs: updatedLogs,
        pendingSyncCount: state.pendingSyncCount + 1,
      );

      // Try to sync immediately if online
      await _trySyncIfOnline();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateQuantity({
    required String customerId,
    required double quantity,
  }) async {
    try {
      final existingLog = state.todayLogs.firstWhere(
        (log) => log.customerId == customerId,
      );

      final updatedLog = existingLog.copyWith(
        quantityDelivered: quantity,
        timestamp: DateTime.now(),
        synced: false,
      );

      // Update in offline queue
      await _syncService.queueDeliveryLog(updatedLog);

      // Update state
      final updatedLogs = state.logs.map((log) {
        return log.customerId == customerId ? updatedLog : log;
      }).toList();

      state = state.copyWith(logs: updatedLogs);

      // Try to sync if online
      await _trySyncIfOnline();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> syncPendingLogs() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      final pendingLogs = await _syncService.getPendingDeliveryLogs();

      if (pendingLogs.isEmpty) {
        state = state.copyWith(isSyncing: false, pendingSyncCount: 0);
        return;
      }

      // Sync service handles the actual syncing
      await _syncService.syncDeliveryLogs();

      // After syncing, reload logs from server and offline queue to ensure
      // the UI reflects the authoritative server state. This avoids cases
      // where a stale queued log (unsynced) overrides the server record.
      await loadLogs(date: state.selectedDate);

      state = state.copyWith(isSyncing: false, pendingSyncCount: 0);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Sync failed: ${e.toString()}',
      );
    }
  }

  Future<void> _trySyncIfOnline() async {
    // Sync service automatically handles connectivity
    await _syncService.syncDeliveryLogs();

    // Reload logs after an automatic sync to pick up server-side changes
    // (for example: server-marked deliveries should override stale queued logs).
    try {
      await loadLogs(date: state.selectedDate);
    } catch (_) {
      // Ignore reload errors - the important part is the sync attempt.
    }
  }  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Providers
final deliveryLogProvider =
    StateNotifierProvider<DeliveryLogNotifier, DeliveryLogState>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return DeliveryLogNotifier(syncService, ref);
});
