import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/invoice/invoice.dart';
import '../../../models/delivery/delivery_log.dart';
import '../../../models/holiday/holiday.dart';
import '../../../models/user_role.dart';
import '../../common/application/holiday_provider.dart';
import '../../auth/application/auth_provider.dart';
import '../../../data/providers/remote_data_source_providers.dart';

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
  final Ref _ref;

  CustomerHomeNotifier(this._ref) : super(CustomerHomeState());

  /// Load customer home data
  Future<void> loadHomeData({String? customerId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Determine customer ID from authenticated user
      final authState = _ref.read(authProvider);
      String userId = '';
      bool usedFallback = false;

      authState.maybeWhen(
        authenticated: (user) {
          if (user.id != null && user.id!.isNotEmpty) {
            userId = user.id!;
          } else {
            userId = user.uid;
            usedFallback = true;
          }
        },
        requiresOnboarding: (user) {
          if (user.id != null && user.id!.isNotEmpty) {
            userId = user.id!;
          } else {
            userId = user.uid;
            usedFallback = true;
          }
        },
        orElse: () => throw Exception('User not authenticated'),
      );

      if (userId.isEmpty) throw Exception('User not authenticated');

      final customerIdToUse = customerId ?? userId;

      // Prepare parallel calls
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final invoiceDataSource = _ref.read(invoiceRemoteDataSourceProvider);
      final deliveryDataSource = _ref.read(deliveryLogRemoteDataSourceProvider);

      final results = await Future.wait([
        invoiceDataSource.getInvoices(month: month, page: 1, limit: 1),
        deliveryDataSource.getLogsByCustomer(
          customerId: customerIdToUse,
          startDate: now.subtract(const Duration(days: 10)),
          endDate: now,
        ),
        _ref.read(customerHolidaysProvider(customerIdToUse).future),
      ], eagerError: true);

      final invoices = results[0] as List;
      final currentBill = invoices.isNotEmpty ? invoices.first as Invoice : null;
      final recentDeliveries = (results[1] as List<DeliveryLog>)
        ..sort((a, b) => b.date.compareTo(a.date));
      final activeHolidays = results[2] as List<Holiday>;

      String? warning;
      if (usedFallback) {
        warning = 'Using Firebase UID as customer identifier; backend ObjectId missing locally.';
      }

      state = state.copyWith(
        currentMonthBill: currentBill,
        recentDeliveries: recentDeliveries,
        activeHolidays: activeHolidays,
        isLoading: false,
        error: warning,
      );
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Session expired. Please login again.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load home data: $e',
        );
      }
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

  // Removed mock generators; production data is fetched from remote data sources.
}

/// Customer home provider
final customerHomeProvider =
    StateNotifierProvider<CustomerHomeNotifier, CustomerHomeState>(
  (ref) => CustomerHomeNotifier(ref),
);
