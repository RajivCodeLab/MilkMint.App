import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/payment_provider.dart';
import '../../application/customer_provider.dart';
import '../widgets/payment_card.dart';
import '../widgets/record_payment_dialog.dart';

/// Payments screen for vendors to track and record payments
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    // Load payments and customers on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).loadPayments();
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final customerState = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentProvider.notifier).loadPayments(),
        child: paymentState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Stats summary
                  _buildStatsSection(paymentState),

                  // Filter chips
                  _buildFilterChips(paymentState),

                  // Payment list
                  Expanded(
                    child: paymentState.filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: paymentState.filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = paymentState.filteredPayments[index];
                              final customer = customerState.customers
                                  .where((c) => c.customerId == payment.customerId)
                                  .firstOrNull;

                              return PaymentCard(
                                payment: payment,
                                customerName: customer?.name ?? 'Unknown',
                                customerPhone: customer?.phone,
                                onTapUpi: customer != null
                                    ? () => _launchUpiPayment(
                                          customer.phone,
                                          payment.amount,
                                        )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordPaymentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildStatsSection(PaymentState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Column(
        children: [
          // Total amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Collected',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        '₹${state.totalAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${state.totalCount} payments',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Mode breakdown
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  'Cash',
                  '₹${state.cashAmount.toStringAsFixed(0)}',
                  '${state.cashCount} txns',
                  Icons.money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  'UPI',
                  '₹${state.upiAmount.toStringAsFixed(0)}',
                  '${state.upiCount} txns',
                  Icons.phonelink,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  'Bank',
                  '₹${state.bankTransferAmount.toStringAsFixed(0)}',
                  '${state.bankTransferCount} txns',
                  Icons.account_balance,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(String label, String amount, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(PaymentState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', state.totalCount),
            const SizedBox(width: 8),
            _buildFilterChip('Cash', 'cash', state.cashCount),
            const SizedBox(width: 8),
            _buildFilterChip('UPI', 'upi', state.upiCount),
            const SizedBox(width: 8),
            _buildFilterChip('Bank Transfer', 'bank_transfer', state.bankTransferCount),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final paymentState = ref.watch(paymentProvider);
    final isSelected = paymentState.selectedFilter == value;
    
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(paymentProvider.notifier).changeFilter(value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No payments found',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record your first payment to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Payments',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Payments'),
              onTap: () {
                ref.read(paymentProvider.notifier).changeFilter('all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Cash Only'),
              onTap: () {
                ref.read(paymentProvider.notifier).changeFilter('cash');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phonelink, color: Colors.blue),
              title: const Text('UPI Only'),
              onTap: () {
                ref.read(paymentProvider.notifier).changeFilter('upi');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.orange),
              title: const Text('Bank Transfer Only'),
              onTap: () {
                ref.read(paymentProvider.notifier).changeFilter('bank_transfer');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRecordPaymentDialog(BuildContext context) async {
    final customerState = ref.read(customerProvider);
    
    if (customerState.customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add customers first')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        customers: customerState.customers,
        onRecord: (customerId, amount, mode, invoiceId, transactionId, notes) async {
          await ref.read(paymentProvider.notifier).recordPayment(
                customerId: customerId,
                amount: amount,
                mode: mode,
                invoiceId: invoiceId,
                transactionId: transactionId,
                notes: notes,
              );
        },
      ),
    );
  }

  Future<void> _launchUpiPayment(String phone, double amount) async {
    // UPI deep link format: upi://pay?pa=UPI_ID&pn=NAME&am=AMOUNT&cu=INR
    // For demo, using a generic UPI ID (in production, use vendor's actual UPI ID)
    final upiId = 'vendor@upi'; // TODO: Get from vendor profile
    final upiUrl = Uri.parse(
      'upi://pay?pa=$upiId&pn=MilkBill&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Milk Payment',
    );

    try {
      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No UPI app found. Please install a UPI app.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch UPI: $e')),
        );
      }
    }
  }
}
