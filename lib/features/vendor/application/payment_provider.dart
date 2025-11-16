import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/payment/payment.dart';
import '../../../data/providers/remote_data_source_providers.dart';

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
  final Ref _ref;

  PaymentNotifier(this._ref) : super(PaymentState());

  /// Load payments
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final remoteDs = _ref.read(paymentRemoteDataSourceProvider);
      
      final payments = await remoteDs.getPayments();

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
      final remoteDs = _ref.read(paymentRemoteDataSourceProvider);
      
      final newPayment = await remoteDs.recordPayment(
        customerId: customerId,
        amount: amount,
        mode: mode,
        paymentDate: DateTime.now(),
        invoiceId: invoiceId,
        transactionId: transactionId,
        notes: notes,
      );

      state = state.copyWith(
        payments: [newPayment, ...state.payments],
        isRecording: false,
      );
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
}

/// Payment provider
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(ref),
);
