import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/customer/customer.dart';
import '../../application/customer_provider.dart';

/// Edit customer screen
class EditCustomerScreen extends ConsumerStatefulWidget {
  const EditCustomerScreen({super.key});

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _quantityController;
  late TextEditingController _rateController;
  
  late String _selectedFrequency;
  late bool _isActive;
  bool _isSaving = false;
  bool _isDeleting = false;
  Customer? _customer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_customer == null) {
      _customer = ModalRoute.of(context)!.settings.arguments as Customer;
      
      _nameController = TextEditingController(text: _customer!.name);
      _phoneController = TextEditingController(
        text: _customer!.phone.replaceFirst('+91', ''),
      );
      _addressController = TextEditingController(text: _customer!.address);
      _quantityController = TextEditingController(
        text: _customer!.quantity.toString(),
      );
      _rateController = TextEditingController(
        text: _customer!.rate.toString(),
      );
      _selectedFrequency = _customer!.frequency;
      _isActive = _customer!.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_customer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Customer Name *',
                hintText: 'Enter customer name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: '9876543210',
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                  return 'Please enter a valid Indian mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Enter delivery address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Delivery Details Header
            Text(
              'Delivery Details',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),

            // Quantity and Rate Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity (Liters) *',
                      hintText: 'e.g., 1.5',
                      prefixIcon: const Icon(Icons.local_drink),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Invalid';
                      }
                      if (quantity > 10) {
                        return 'Max 10L';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate/Liter *',
                      hintText: 'e.g., 50',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frequency Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Frequency *',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['daily', 'alternate', 'weekly', 'custom'].map((frequency) {
                      final isSelected = _selectedFrequency == frequency;
                        return ChoiceChip(
                          label: Text(
                            _getFrequencyLabel(frequency),
                            style: isSelected
                                ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
                                : null,
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFrequency = frequency;
                            });
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                          elevation: isSelected ? 1 : 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Status Switch
            SwitchListTile(
              title: const Text('Active Customer'),
              subtitle: Text(
                _isActive
                    ? 'Customer will receive daily deliveries'
                    : 'Deliveries paused for this customer',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              tileColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _updateCustomer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Update Customer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'alternate':
        return 'Alternate Days';
      case 'weekly':
        return 'Weekly';
      case 'custom':
        return 'Custom';
      default:
        return frequency;
    }
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedCustomer = _customer!.copyWith(
        name: _nameController.text.trim(),
        phone: '+91${_phoneController.text.trim()}',
        address: _addressController.text.trim(),
        quantity: double.parse(_quantityController.text),
        rate: double.parse(_rateController.text),
        frequency: _selectedFrequency,
        active: _isActive,
      );

      await ref.read(customerProvider.notifier).updateCustomer(updatedCustomer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedCustomer.name} updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${_customer!.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomer();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(customerProvider.notifier).deleteCustomer(
            _customer!.customerId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_customer!.name} deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}

