import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/delivery/delivery_log.dart';

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
  DeliveryHistoryNotifier() : super(const DeliveryHistoryState()) {
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
      // TODO: Replace with actual API call
      // final response = await _apiClient.get('/delivery-logs?customerId=$customerId&month=${month.toIso8601String()}');
      
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data: Generate deliveries for the selected month
      final mockDeliveries = _generateMockDeliveries(customerId, month);

      state = state.copyWith(
        deliveries: mockDeliveries,
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

  /// Generate mock data for development
  List<DeliveryLog> _generateMockDeliveries(String customerId, DateTime month) {
    final deliveries = <DeliveryLog>[];
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      
      // Only generate for dates up to today
      if (date.isAfter(now)) break;

      // Skip some days randomly (holidays/no delivery)
      if (day % 7 == 0 || day % 11 == 0) continue;

      final delivered = day % 5 != 0; // Miss delivery every 5th day
      
      deliveries.add(
        DeliveryLog(
          id: 'log_${month.month}_$day',
          vendorId: 'vendor_123',
          customerId: customerId,
          date: date,
          delivered: delivered,
          quantityDelivered: delivered ? 2.0 : 0.0,
          notes: delivered 
              ? null 
              : day % 10 == 0 
                  ? 'Holiday - No delivery requested'
                  : 'Missed delivery',
          timestamp: date.add(const Duration(hours: 6)),
          synced: true,
          syncedAt: date.add(const Duration(hours: 6, minutes: 5)),
        ),
      );
    }

    return deliveries;
  }
}

final deliveryHistoryProvider =
    StateNotifierProvider<DeliveryHistoryNotifier, DeliveryHistoryState>((ref) {
  return DeliveryHistoryNotifier();
});
