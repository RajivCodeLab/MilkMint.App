import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/payment/payment.dart';

/// Payment state
class PaymentState {
  final List<Payment> payments;
  final bool isLoading;
  final bool isRecording;
  final String? error;
  final String selectedFilter; // all, cash, upi, bank_transfer

  PaymentState({
    this.payments = const [],
    this.isLoading = false,
    this.isRecording = false,
    this.error,
    this.selectedFilter = 'all',
  });

  PaymentState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    bool? isRecording,
    String? error,
    String? selectedFilter,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  // Filter payments by mode
  List<Payment> get filteredPayments {
    if (selectedFilter == 'all') return payments;
    return payments.where((p) => p.mode == selectedFilter).toList();
  }

  // Computed properties
  double get totalAmount =>
      payments.fold(0, (sum, payment) => sum + payment.amount);

  double get cashAmount => payments
      .where((p) => p.mode == 'cash')
      .fold(0, (sum, p) => sum + p.amount);

  double get upiAmount => payments
      .where((p) => p.mode == 'upi')
      .fold(0, (sum, p) => sum + p.amount);

  double get bankTransferAmount => payments
      .where((p) => p.mode == 'bank_transfer')
      .fold(0, (sum, p) => sum + p.amount);

  int get totalCount => payments.length;
  
  int get cashCount => payments.where((p) => p.mode == 'cash').length;
  
  int get upiCount => payments.where((p) => p.mode == 'upi').length;
  
  int get bankTransferCount =>
      payments.where((p) => p.mode == 'bank_transfer').length;

  // Get payments for a specific customer
  List<Payment> paymentsForCustomer(String customerId) {
    return payments.where((p) => p.customerId == customerId).toList();
  }
}

/// Payment notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(PaymentState());

  /// Load payments
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      // final response = await apiClient.get('/payments?vendorId=...');
      // final payments = (response.data as List)
      //     .map((json) => Payment.fromJson(json))
      //     .toList();

      // Mock data for development
      await Future.delayed(const Duration(seconds: 1));
      final payments = _generateMockPayments();

      state = state.copyWith(
        payments: payments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load payments: $e',
      );
    }
  }

  /// Record a new payment
  Future<void> recordPayment({
    required String customerId,
    required double amount,
    required String mode,
    String? invoiceId,
    String? transactionId,
    String? notes,
  }) async {
    state = state.copyWith(isRecording: true, error: null);

    try {
      // TODO: Replace with actual API call
      // final response = await apiClient.post('/payments', data: {
      //   'customerId': customerId,
      //   'amount': amount,
      //   'mode': mode,
      //   'invoiceId': invoiceId,
      //   'transactionId': transactionId,
      //   'notes': notes,
      // });
      // final newPayment = Payment.fromJson(response.data);

      // Mock response
      await Future.delayed(const Duration(seconds: 1));
      final newPayment = Payment(
        id: 'PAY${state.payments.length + 1}',
        paymentId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        vendorId: 'VENDOR001',
        customerId: customerId,
        invoiceId: invoiceId,
        amount: amount,
        mode: mode,
        transactionId: transactionId,
        notes: notes,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        payments: [newPayment, ...state.payments],
        isRecording: false,
      );

      // TODO: Queue offline action if needed
      // OfflineQueueManager().queueAction('payment', newPayment.toJson());
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        error: 'Failed to record payment: $e',
      );
    }
  }

  /// Change filter
  void changeFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Generate mock payments for development
  List<Payment> _generateMockPayments() {
    final now = DateTime.now();
    final customers = [
      {'id': 'CUST001', 'name': 'Rajesh Kumar'},
      {'id': 'CUST002', 'name': 'Priya Sharma'},
      {'id': 'CUST003', 'name': 'Amit Patel'},
      {'id': 'CUST004', 'name': 'Sneha Reddy'},
      {'id': 'CUST005', 'name': 'Vikram Singh'},
    ];

    final modes = ['cash', 'upi', 'bank_transfer'];
    final payments = <Payment>[];

    for (int i = 0; i < 15; i++) {
      final customer = customers[i % customers.length];
      final mode = modes[i % modes.length];
      final amount = (500.0 + (i * 150)) % 4000;
      final daysAgo = i * 2;

      payments.add(Payment(
        id: 'PAY${i + 1}',
        paymentId: 'PAY-2025-${(i + 1).toString().padLeft(4, '0')}',
        vendorId: 'VENDOR001',
        customerId: customer['id'] as String,
        invoiceId: i % 3 == 0 ? 'INV-2025-${(i + 1).toString().padLeft(3, '0')}' : null,
        amount: amount,
        mode: mode,
        transactionId: mode != 'cash' ? 'TXN${DateTime.now().millisecondsSinceEpoch + i}' : null,
        notes: i % 4 == 0 ? 'Monthly payment' : null,
        timestamp: now.subtract(Duration(days: daysAgo)),
        createdAt: now.subtract(Duration(days: daysAgo)),
        updatedAt: now.subtract(Duration(days: daysAgo)),
      ));
    }

    return payments..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

/// Payment provider
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(),
);
