import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../data/providers/remote_data_source_providers.dart';

part 'delivery_history_provider.freezed.dart';

@freezed
class DeliveryHistoryState with _$DeliveryHistoryState {
  const factory DeliveryHistoryState({
    @Default([]) List<DeliveryLog> deliveries,
    @Default(false) bool isLoading,
    String? error,
    DateTime? selectedMonth,
  }) = _DeliveryHistoryState;
}

class DeliveryHistoryNotifier extends StateNotifier<DeliveryHistoryState> {
  final Ref _ref;

  DeliveryHistoryNotifier(this._ref) : super(const DeliveryHistoryState()) {
    _initialize();
  }

  void _initialize() {
    final now = DateTime.now();
    changeMonth(DateTime(now.year, now.month));
  }

  /// Load deliveries for a specific month
  Future<void> loadDeliveries({required String customerId, required DateTime month}) async {
    state = state.copyWith(isLoading: true, error: null, selectedMonth: month);

    try {
      final deliveryDataSource = _ref.read(deliveryLogRemoteDataSourceProvider);

      // Calculate month start and end
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      final logs = await deliveryDataSource.getLogsByCustomer(
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        deliveries: logs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change selected month and reload deliveries
  Future<void> changeMonth(DateTime month, {String? customerId}) async {
    if (customerId != null) {
      await loadDeliveries(customerId: customerId, month: month);
    } else {
      state = state.copyWith(selectedMonth: month);
    }
  }

  /// Get deliveries grouped by date
  Map<DateTime, List<DeliveryLog>> get deliveriesByDate {
    final grouped = <DateTime, List<DeliveryLog>>{};
    
    for (final delivery in state.deliveries) {
      final dateOnly = DateTime(
        delivery.date.year,
        delivery.date.month,
        delivery.date.day,
      );
      
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(delivery);
    }

    // Sort dates in descending order (most recent first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  /// Get summary statistics
  int get totalDeliveries => state.deliveries.where((d) => d.delivered).length;
  
  int get totalMissedDeliveries => state.deliveries.where((d) => !d.delivered).length;
  
  double get totalLiters => state.deliveries
      .where((d) => d.delivered)
      .fold(0.0, (sum, d) => sum + (d.quantityDelivered ?? 0.0));
  
  double get deliveryRate {
    if (state.deliveries.isEmpty) return 0.0;
    return (totalDeliveries / state.deliveries.length) * 100;
  }

  // Mock generator removed; deliveries are fetched from backend via remote data source.
}

final deliveryHistoryProvider =
    StateNotifierProvider<DeliveryHistoryNotifier, DeliveryHistoryState>((ref) {
  return DeliveryHistoryNotifier(ref);
});
