import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/invoice/invoice.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../models/holiday/holiday.dart';

/// Customer home state
class CustomerHomeState {
  final Invoice? currentMonthBill;
  final List<DeliveryLog> recentDeliveries;
  final List<Holiday> activeHolidays;
  final bool isLoading;
  final String? error;

  CustomerHomeState({
    this.currentMonthBill,
    this.recentDeliveries = const [],
    this.activeHolidays = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerHomeState copyWith({
    Invoice? currentMonthBill,
    List<DeliveryLog>? recentDeliveries,
    List<Holiday>? activeHolidays,
    bool? isLoading,
    String? error,
  }) {
    return CustomerHomeState(
      currentMonthBill: currentMonthBill ?? this.currentMonthBill,
      recentDeliveries: recentDeliveries ?? this.recentDeliveries,
      activeHolidays: activeHolidays ?? this.activeHolidays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Computed properties
  bool get hasPendingDues => currentMonthBill != null && !currentMonthBill!.paid;
  
  double get pendingAmount => hasPendingDues ? currentMonthBill!.amount : 0.0;

  int get deliveriesThisMonth => recentDeliveries
      .where((d) => d.delivered && _isCurrentMonth(d.date))
      .length;

  double get totalLitersThisMonth => recentDeliveries
      .where((d) => d.delivered && _isCurrentMonth(d.date))
      .fold(0, (sum, d) => sum + (d.quantityDelivered ?? 0.0));

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

/// Customer home notifier
class CustomerHomeNotifier extends StateNotifier<CustomerHomeState> {
  CustomerHomeNotifier() : super(CustomerHomeState());

  /// Load customer home data
  Future<void> loadHomeData({String? customerId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API calls
      // final billResponse = await apiClient.get('/invoices/current?customerId=$customerId');
      // final deliveriesResponse = await apiClient.get('/delivery-logs/recent?customerId=$customerId');
      // final holidaysResponse = await apiClient.get('/holidays/active?customerId=$customerId');

      // Mock data for development
      await Future.delayed(const Duration(seconds: 1));
      
      final mockBill = _generateMockBill();
      final mockDeliveries = _generateMockDeliveries();
      final mockHolidays = _generateMockHolidays();

      state = state.copyWith(
        currentMonthBill: mockBill,
        recentDeliveries: mockDeliveries,
        activeHolidays: mockHolidays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load home data: $e',
      );
    }
  }

  /// Request holiday
  Future<void> requestHoliday({
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      // TODO: Replace with actual API call
      // await apiClient.post('/holidays', data: {
      //   'startDate': startDate.toIso8601String(),
      //   'endDate': endDate.toIso8601String(),
      //   'reason': reason,
      // });

      await Future.delayed(const Duration(seconds: 1));

      final newHoliday = Holiday(
        id: 'HOL${state.activeHolidays.length + 1}',
        customerId: 'CUST001',
        vendorId: 'VENDOR001',
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        activeHolidays: [...state.activeHolidays, newHoliday],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to request holiday: $e');
      rethrow;
    }
  }

  /// Generate mock bill
  Invoice _generateMockBill() {
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    return Invoice(
      id: 'INV1',
      invoiceId: 'INV-$month-001',
      vendorId: 'VENDOR001',
      customerId: 'CUST001',
      month: month,
      year: now.year,
      totalLiters: 60.0,
      amount: 3000.0,
      pdfUrl: 'https://example.com/invoices/INV-$month-001.pdf',
      paid: false,
      generatedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate mock deliveries
  List<DeliveryLog> _generateMockDeliveries() {
    final now = DateTime.now();
    final deliveries = <DeliveryLog>[];

    for (int i = 0; i < 10; i++) {
      final date = now.subtract(Duration(days: i));
      deliveries.add(DeliveryLog(
        id: 'LOG${i + 1}',
        vendorId: 'VENDOR001',
        customerId: 'CUST001',
        date: date,
        delivered: i % 4 != 0, // Every 4th day not delivered
        quantityDelivered: i % 4 != 0 ? 2.0 : null,
        timestamp: date,
        synced: true,
        syncedAt: date,
      ));
    }

    return deliveries;
  }

  /// Generate mock holidays
  List<Holiday> _generateMockHolidays() {
    final now = DateTime.now();
    return [
      Holiday(
        id: 'HOL1',
        customerId: 'CUST001',
        vendorId: 'VENDOR001',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 15)),
        reason: 'Vacation',
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}

/// Customer home provider
final customerHomeProvider =
    StateNotifierProvider<CustomerHomeNotifier, CustomerHomeState>(
  (ref) => CustomerHomeNotifier(),
);
