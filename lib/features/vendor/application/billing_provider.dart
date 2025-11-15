import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/invoice/invoice.dart';

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
  BillingNotifier() : super(BillingState());

  /// Load invoices for selected month
  Future<void> loadInvoices({String? month}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedMonth: month,
    );

    try {
      // TODO: Replace with actual API call
      // final response = await apiClient.get('/invoices/${state.selectedMonth}');
      // final invoices = (response.data as List)
      //     .map((json) => Invoice.fromJson(json))
      //     .toList();

      // Mock data for development
      await Future.delayed(const Duration(seconds: 1));
      final invoices = _generateMockInvoices(state.selectedMonth);

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
      // TODO: Replace with actual API call
      // final response = await apiClient.post('/invoices/generate', data: {
      //   'month': state.selectedMonth,
      //   if (customerId != null) 'customerId': customerId,
      // });

      // Mock response
      await Future.delayed(const Duration(seconds: 2));

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

  /// Mark invoice as paid (offline action)
  void markAsPaid(String invoiceId) {
    final updatedInvoices = state.invoices.map((inv) {
      if (inv.invoiceId == invoiceId) {
        return inv.copyWith(paid: true, paidAt: DateTime.now());
      }
      return inv;
    }).toList();

    state = state.copyWith(invoices: updatedInvoices);

    // TODO: Queue offline action and sync to backend
    // OfflineQueueManager().queueAction('invoice_payment', {...});
  }

  /// Generate mock invoices for development
  List<Invoice> _generateMockInvoices(String month) {
    final monthDate = DateTime.parse('$month-01');
    final customers = [
      {'id': 'CUST001', 'name': 'Rajesh Kumar', 'liters': 60.0, 'rate': 50.0},
      {'id': 'CUST002', 'name': 'Priya Sharma', 'liters': 45.0, 'rate': 55.0},
      {'id': 'CUST003', 'name': 'Amit Patel', 'liters': 30.0, 'rate': 50.0},
      {'id': 'CUST004', 'name': 'Sneha Reddy', 'liters': 75.0, 'rate': 52.0},
      {'id': 'CUST005', 'name': 'Vikram Singh', 'liters': 50.0, 'rate': 48.0},
    ];

    return customers.asMap().entries.map((entry) {
      final index = entry.key;
      final cust = entry.value;
      final liters = cust['liters'] as double;
      final rate = cust['rate'] as double;
      final amount = liters * rate;

      return Invoice(
        id: 'INV${index + 1}',
        invoiceId: 'INV-$month-${(index + 1).toString().padLeft(3, '0')}',
        vendorId: 'VENDOR001',
        customerId: cust['id'] as String,
        month: month,
        year: monthDate.year,
        totalLiters: liters,
        amount: amount,
        pdfUrl: index < 3
            ? 'https://example.com/invoices/${cust['id']}-$month.pdf'
            : null,
        paid: index % 3 == 0, // Every 3rd invoice is paid
        paidAt: index % 3 == 0 ? DateTime.now().subtract(Duration(days: index)) : null,
        generatedAt: DateTime.now().subtract(Duration(days: index + 1)),
        createdAt: DateTime.now().subtract(Duration(days: index + 2)),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }
}

/// Billing provider
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>(
  (ref) => BillingNotifier(),
);
