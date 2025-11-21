import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/customer/customer.dart';

class RecordPaymentDialog extends StatefulWidget {
  final List<Customer> customers;
  final Future<void> Function(
    String customerId,
    double amount,
    String mode,
    String? invoiceId,
    String? transactionId,
    String? notes,
  ) onRecord;

  const RecordPaymentDialog({
    super.key,
    required this.customers,
    required this.onRecord,
  });

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _invoiceIdController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCustomerId;
  String _selectedMode = 'cash';
  bool _isRecording = false;

  @override
  void dispose() {
    _amountController.dispose();
    _invoiceIdController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Record Payment',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Customer dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: widget.customers.map((customer) {
                    return DropdownMenuItem(
                      value: customer.customerId,
                      child: Text(customer.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomerId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Payment mode selector
                Text(
                  'Payment Mode',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.money, size: 16),
                          SizedBox(width: 4),
                          Text('Cash'),
                        ],
                      ),
                      selected: _selectedMode == 'cash',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMode = 'cash';
                            _transactionIdController.clear();
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phonelink, size: 16),
                          SizedBox(width: 4),
                          Text('UPI'),
                        ],
                      ),
                      selected: _selectedMode == 'upi',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMode = 'upi';
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance, size: 16),
                          SizedBox(width: 4),
                          Text('Bank Transfer'),
                        ],
                      ),
                      selected: _selectedMode == 'bank_transfer',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMode = 'bank_transfer';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Invoice ID (optional)
                TextFormField(
                  controller: _invoiceIdController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice ID (Optional)',
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction ID (for digital payments)
                if (_selectedMode != 'cash') ...[
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Transaction ID',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedMode != 'cash' && (value == null || value.isEmpty)) {
                        return 'Transaction ID required for digital payments';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes (optional)
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isRecording ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isRecording ? null : _recordPayment,
                        child: _isRecording
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Record'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      await widget.onRecord(
        _selectedCustomerId!,
        double.parse(_amountController.text),
        _selectedMode,
        _invoiceIdController.text.isNotEmpty ? _invoiceIdController.text : null,
        _transactionIdController.text.isNotEmpty ? _transactionIdController.text : null,
        _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }
}
