import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../core/offline/offline_sync_service.dart';

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
    final today = DateTime.now();
    return logs.where((log) {
      return log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
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

  DeliveryLogNotifier(this._syncService)
      : super(DeliveryLogState()) {
    _initSyncListener();
  }

  void _initSyncListener() {
    _syncService.syncStatusStream.listen((syncStatus) {
      state = state.copyWith(
        isSyncing: syncStatus.isSyncing,
        pendingSyncCount: syncStatus.pendingCount,
      );
    });
  }

  Future<void> loadLogs({DateTime? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Load from offline queue
      final queuedLogs = await _syncService.getPendingDeliveryLogs();
      
      // Mock data for development
      final mockLogs = _generateMockLogs(date ?? DateTime.now());
      
      state = state.copyWith(
        logs: [...mockLogs, ...queuedLogs],
        isLoading: false,
        pendingSyncCount: queuedLogs.length,
        selectedDate: date,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleDelivery({
    required String customerId,
    required String customerName,
    required double quantity,
  }) async {
    try {
      final existingLog = state.todayLogs.firstWhere(
        (log) => log.customerId == customerId,
        orElse: () => DeliveryLog(
          vendorId: 'vendor1', // TODO: Get from auth
          customerId: customerId,
          date: DateTime.now(),
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

      // Update state with synced logs
      final updatedLogs = state.logs.map((log) {
        if (pendingLogs.any((p) => p.id == log.id)) {
          return log.copyWith(synced: true);
        }
        return log;
      }).toList();

      state = state.copyWith(
        logs: updatedLogs,
        isSyncing: false,
        pendingSyncCount: 0,
      );
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
  }  void clearError() {
    state = state.copyWith(error: null);
  }

  List<DeliveryLog> _generateMockLogs(DateTime date) {
    // Generate mock logs for testing
    return [];
  }
}

/// Providers
final deliveryLogProvider =
    StateNotifierProvider<DeliveryLogNotifier, DeliveryLogState>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return DeliveryLogNotifier(syncService);
});
