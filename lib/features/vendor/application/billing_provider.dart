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
  final List<String>? lastGeneratedCustomerIds;

  BillingState({
    this.invoices = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    String? selectedMonth,
    this.lastGeneratedCustomerIds,
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
    List<String>? lastGeneratedCustomerIds,
  }) {
    return BillingState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      lastGeneratedCustomerIds: lastGeneratedCustomerIds ?? this.lastGeneratedCustomerIds,
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

  /// Generate invoice for all customers or a subset.
  ///
  /// If `customerIds` is null or empty, generates for all customers.
  /// Backend currently only supports batch generation for all customers
  /// (`/invoices/generate`). To support generating for a selected subset,
  /// we generate for all and then delete invoices for customers that were
  /// not selected. This keeps the server as the source of truth while
  /// providing the vendor UX to pick specific customers.
  /// Generate invoices for a set of customers (or all when `customerIds` is null).
  /// Returns the list of customerIds for which invoices exist after generation.
  Future<List<String>> generateInvoice({List<String>? customerIds}) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final remoteDs = _ref.read(invoiceRemoteDataSourceProvider);

      // Generate invoices for the month. Backend now accepts optional
      // `customerIds` to limit generation to a subset of customers.
      await remoteDs.generateInvoices(
        month: state.selectedMonth,
        force: false,
        customerIds: customerIds,
      );

      // Reload invoices after generation
      await loadInvoices(month: state.selectedMonth);

      // Determine which customers have invoices for the month
      final generatedCustomerIds = state.invoices
          .where((inv) => inv.month == state.selectedMonth)
          .map((inv) => inv.customerId)
          .toSet()
          .toList();

      state = state.copyWith(
        isGenerating: false,
        lastGeneratedCustomerIds: generatedCustomerIds,
      );

      return generatedCustomerIds;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate invoice: $e',
      );
      rethrow;
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
      
      final updated = await remoteDs.markInvoiceAsPaid(invoiceId);

      // Replace invoice in local state with returned invoice values
      final updatedInvoices = state.invoices.map((inv) {
        if (inv.invoiceId == invoiceId) {
          return inv.copyWith(
            paid: updated.paid,
            paidAt: updated.paidAt ?? DateTime.now(),
            pdfUrl: updated.pdfUrl ?? inv.pdfUrl,
            amount: updated.amount != 0 ? updated.amount : inv.amount,
            totalLiters: updated.totalLiters != 0 ? updated.totalLiters : inv.totalLiters,
          );
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
