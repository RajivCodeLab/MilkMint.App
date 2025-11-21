import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/billing_provider.dart';
import '../../application/customer_provider.dart';
import '../widgets/billing_invoice_card.dart';

/// Billing screen for vendors to manage monthly invoices
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String _selectedFilter = 'all'; // all, paid, unpaid

  @override
  void initState() {
    super.initState();
    // Load invoices on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billingProvider.notifier).loadInvoices();
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final customerState = ref.watch(customerProvider);

    // Filter invoices based on selected filter
    final filteredInvoices = _selectedFilter == 'paid'
        ? billingState.paidInvoices
        : _selectedFilter == 'unpaid'
            ? billingState.unpaidInvoices
            : billingState.invoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          // Month selector
          TextButton.icon(
            onPressed: () => _selectMonth(context),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(_formatMonth(billingState.selectedMonth)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(billingProvider.notifier).loadInvoices(),
        child: billingState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Stats summary
                  _buildStatsSection(billingState),

                  // Filter chips
                  _buildFilterChips(billingState),

                  // Invoice list
                  Expanded(
                    child: filteredInvoices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = filteredInvoices[index];
                              final customer = customerState.customers
                                  .where((c) =>
                                      c.customerId == invoice.customerId)
                                  .firstOrNull;

                              return BillingInvoiceCard(
                                invoice: invoice,
                                customerName: customer?.name ?? 'Unknown',
                                onViewPdf: () => _viewPdf(invoice.pdfUrl),
                                onMarkPaid: () => _markAsPaid(invoice.invoiceId),
                                onShare: () => _shareInvoice(invoice),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: billingState.isGenerating
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FloatingActionButton.extended(
              onPressed: _generateInvoices,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generate Invoices'),
            ),
    );
  }

  Widget _buildStatsSection(BillingState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '₹${state.totalAmount.toStringAsFixed(0)}',
              '${state.totalInvoices} invoices',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Paid',
              '₹${state.paidAmount.toStringAsFixed(0)}',
              '${state.paidCount} invoices',
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Unpaid',
              '₹${state.unpaidAmount.toStringAsFixed(0)}',
              '${state.unpaidCount} invoices',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BillingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All', 'all', state.totalInvoices),
          const SizedBox(width: 8),
          _buildFilterChip('Paid', 'paid', state.paidCount),
          const SizedBox(width: 8),
          _buildFilterChip('Unpaid', 'unpaid', state.unpaidCount),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
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
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No invoices found',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate invoices for ${_formatMonth(ref.read(billingProvider).selectedMonth)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String month) {
    final date = DateTime.parse('$month-01');
    return DateFormat('MMM yyyy').format(date);
  }

  Future<void> _selectMonth(BuildContext context) async {
    final currentMonth = DateTime.parse('${ref.read(billingProvider).selectedMonth}-01');

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month',
    );

    if (selectedDate != null) {
      final monthString =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
      ref.read(billingProvider.notifier).changeMonth(monthString);
    }
  }

  Future<void> _generateInvoices() async {
    // Show a multi-select dialog listing all customers so vendor can
    // choose to generate for all or a selected subset.
    final customerState = ref.read(customerProvider);
    final customers = customerState.customers;

    if (customers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No customers to generate invoices for')),
        );
      }
      return;
    }

    final selected = <String>{};
    final allSelected = ValueNotifier<bool>(true);

    // By default select all
    for (final c in customers) {
      selected.add(c.customerId);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Generate Invoices'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select customers to generate invoices for ${_formatMonth(ref.read(billingProvider).selectedMonth)}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: allSelected,
                          builder: (context, value, _) {
                            return Checkbox(
                              value: value,
                              onChanged: (v) {
                                final check = v ?? false;
                                dialogSetState(() {
                                  allSelected.value = check;
                                  if (check) {
                                    selected.clear();
                                    for (final c in customers) {
                                      selected.add(c.customerId);
                                    }
                                  } else {
                                    selected.clear();
                                  }
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('Select All'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final c = customers[index];
                          final isSelected = selected.contains(c.customerId);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(c.name),
                            subtitle: Text(c.phone),
                            onChanged: (v) {
                              dialogSetState(() {
                                if (v == true) {
                                  selected.add(c.customerId);
                                } else {
                                  selected.remove(c.customerId);
                                }
                                allSelected.value = selected.length == customers.length;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      // If all selected, pass null to generate for all (server default).
      final customerIds = selected.length == customers.length ? null : selected.toList();

      List<String> generatedIds = const [];
      try {
        generatedIds = await ref.read(billingProvider.notifier).generateInvoice(customerIds: customerIds);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate invoices: $e')),
          );
        }
        return;
      }

      // Map generated ids to customer names for display
      final idToCustomer = {for (var c in customers) c.customerId: c};
      final generatedCustomers = generatedIds.map((id) => idToCustomer[id]).where((c) => c != null).cast().toList();

      if (mounted) {
        // Show summary dialog with list of customers included
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invoices Generated'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generated invoices for ${generatedCustomers.length} customers'),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: generatedCustomers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = generatedCustomers[index];
                          return ListTile(
                            dense: true,
                            title: Text(c.name),
                            subtitle: Text(c.phone),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _viewPdf(String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not yet generated')),
      );
      return;
    }

    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open PDF')),
        );
      }
    }
  }

  Future<void> _markAsPaid(String invoiceId) async {
    try {
      await ref.read(billingProvider.notifier).markAsPaid(invoiceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice marked as paid')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark invoice as paid: $e')),
        );
      }
    }
  }

  Future<void> _shareInvoice(invoice) async {
    if (invoice.pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not yet generated')),
      );
      return;
    }

    // WhatsApp share
    final message = Uri.encodeComponent(
      'Your milk bill for ${_formatMonth(invoice.month)}: ₹${invoice.amount.toStringAsFixed(2)}\n'
      'Total: ${invoice.totalLiters}L\n'
      'View invoice: ${invoice.pdfUrl}',
    );

    final whatsappUrl = Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open WhatsApp')),
        );
      }
    }
  }
}
