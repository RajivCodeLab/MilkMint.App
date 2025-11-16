import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/invoice/invoice.dart';
import '../../../data/providers/remote_data_source_providers.dart';

/// Billing state
class BillingState {
  final List<Invoice> invoices;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final String selectedMonth; // Format: "YYYY-MM"

  BillingState({
    this.invoices = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    String? selectedMonth,
  }) : selectedMonth = selectedMonth ?? _getCurrentMonth();

  static String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  BillingState copyWith({
    List<Invoice>? invoices,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    String? selectedMonth,
  }) {
    return BillingState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  // Computed properties
  List<Invoice> get paidInvoices =>
      invoices.where((inv) => inv.paid).toList();

  List<Invoice> get unpaidInvoices =>
      invoices.where((inv) => !inv.paid).toList();

  double get totalAmount =>
      invoices.fold(0, (sum, inv) => sum + inv.amount);

  double get paidAmount =>
      paidInvoices.fold(0, (sum, inv) => sum + inv.amount);

  double get unpaidAmount =>
      unpaidInvoices.fold(0, (sum, inv) => sum + inv.amount);

  int get totalInvoices => invoices.length;
  int get paidCount => paidInvoices.length;
  int get unpaidCount => unpaidInvoices.length;
}

/// Billing notifier
class BillingNotifier extends StateNotifier<BillingState> {
  final Ref _ref;

  BillingNotifier(this._ref) : super(BillingState());

  /// Load invoices for selected month
  Future<void> loadInvoices({String? month}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedMonth: month,
    );

    try {
      final remoteDs = _ref.read(invoiceRemoteDataSourceProvider);
      
      // Get invoices for the selected month
      final invoices = await remoteDs.getInvoices(
        month: state.selectedMonth,
      );

      state = state.copyWith(
        invoices: invoices,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load invoices: $e',
      );
    }
  }

  /// Generate invoice for a specific customer or all customers
  Future<void> generateInvoice({String? customerId}) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final remoteDs = _ref.read(invoiceRemoteDataSourceProvider);
      
      // Note: API generateInvoices doesn't support customerId filter
      // It generates for all customers in the month
      await remoteDs.generateInvoices(
        month: state.selectedMonth,
        force: false,
      );

      // Reload invoices after generation
      await loadInvoices(month: state.selectedMonth);

      state = state.copyWith(isGenerating: false);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate invoice: $e',
      );
    }
  }

  /// Change selected month
  void changeMonth(String month) {
    loadInvoices(month: month);
  }

  /// Mark invoice as paid
  Future<void> markAsPaid(String invoiceId) async {
    try {
      final remoteDs = _ref.read(invoiceRemoteDataSourceProvider);
      
      await remoteDs.markInvoiceAsPaid(invoiceId);
      
      // Update local state optimistically
      final updatedInvoices = state.invoices.map((inv) {
        if (inv.invoiceId == invoiceId) {
          return inv.copyWith(paid: true, paidAt: DateTime.now());
        }
        return inv;
      }).toList();

      state = state.copyWith(invoices: updatedInvoices);
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark invoice as paid: $e');
      rethrow;
    }
  }

}

/// Billing provider
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>(
  (ref) => BillingNotifier(ref),
);
