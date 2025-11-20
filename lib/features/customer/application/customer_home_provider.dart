import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/invoice/invoice.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../models/holiday/holiday.dart';
import '../../../models/user_role.dart';
import '../../common/application/holiday_provider.dart';
import '../../auth/application/auth_provider.dart';

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

  /// Request holiday - now using real backend API
  Future<void> requestHoliday({
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    required WidgetRef ref,
  }) async {
    try {
      // Get current user info from auth state
      final authState = ref.read(authProvider);
      User? user;
      
      authState.maybeWhen(
        authenticated: (u) => user = u,
        requiresOnboarding: (u) => user = u,
        orElse: () => throw Exception('User not authenticated'),
      );

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Use HolidayRepository to create holiday via backend API
      // For customers, use their MongoDB _id from the 'id' field
      // vendorId field stores the vendor's ID for customers
      final holidayRepository = ref.read(holidayRepositoryProvider);
      final customerId = user!.id ?? user!.uid;
      
      if (customerId.isEmpty) {
        throw Exception('Customer ID not found. Please complete onboarding.');
      }
      
      final newHoliday = await holidayRepository.createHoliday(
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      // Backend will send notification to vendor automatically
      // Update local state with new holiday
      state = state.copyWith(
        activeHolidays: [...state.activeHolidays, newHoliday],
      );
    } catch (e) {
      // Parse error for better user message
      String errorMessage = 'Failed to request holiday';
      if (e.toString().contains('Customer with ID') && e.toString().contains('not found')) {
        errorMessage = 'You are not registered as a customer yet. Please ask your milk vendor to add you to their customer list first.';
      } else if (e.toString().contains('does not belong to vendor')) {
        errorMessage = 'You are not associated with any vendor. Please contact your milk vendor.';
      } else {
        errorMessage = 'Failed to request holiday: ${e.toString()}';
      }
      
      state = state.copyWith(error: errorMessage);
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
