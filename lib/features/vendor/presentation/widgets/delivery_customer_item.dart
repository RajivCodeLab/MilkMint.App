import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/customer/customer.dart';
import '../../../../models/delivery/delivery_log.dart';

/// Delivery customer item widget
class DeliveryCustomerItem extends StatefulWidget {
  final Customer customer;
  final DeliveryLog? log;
  final VoidCallback onToggle;
  final Function(double) onQuantityChange;

  const DeliveryCustomerItem({
    super.key,
    required this.customer,
    required this.log,
    required this.onToggle,
    required this.onQuantityChange,
  });

  @override
  State<DeliveryCustomerItem> createState() => _DeliveryCustomerItemState();
}

class _DeliveryCustomerItemState extends State<DeliveryCustomerItem> {
  late TextEditingController _quantityController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _getQuantityDelivered().toString(),
    );
  }

  @override
  void didUpdateWidget(DeliveryCustomerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _quantityController.text = _getQuantityDelivered().toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  bool _isDelivered() {
    return widget.log?.delivered ?? false;
  }

  double _getQuantityDelivered() {
    return widget.log?.quantityDelivered ?? 0.0;
  }

  bool _isSynced() {
    return widget.log?.synced ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = _isDelivered();
    final isSynced = _isSynced();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Checkbox
                Checkbox(
                  value: isDelivered,
                  onChanged: (_) => widget.onToggle(),
                  activeColor: AppColors.success,
                ),
                const SizedBox(width: 8),

                // Customer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.customer.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isDelivered
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDelivered
                                    ? AppColors.textSecondary
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Sync Status
                          if (!isSynced)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_off,
                                    size: 12,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Offline',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customer.address.isNotEmpty
                            ? widget.customer.address
                            : 'No address',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isDelivered) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Quantity Editor
              Row(
                children: [
                  Icon(
                    Icons.local_drink,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quantity:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        // Decrease Button
                        IconButton(
                          onPressed: () => _adjustQuantity(-0.5),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.error,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),

                        // Quantity Input
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              suffixText: 'L',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.surfaceDark 
                                  : Colors.white.withOpacity(0.8),
                            ),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            onChanged: (value) {
                              final quantity = double.tryParse(value);
                              if (quantity != null && quantity > 0) {
                                widget.onQuantityChange(quantity);
                              }
                            },
                            onSubmitted: (value) {
                              setState(() {
                                _isEditing = false;
                              });
                              final quantity = double.tryParse(value);
                              if (quantity != null && quantity > 0) {
                                widget.onQuantityChange(quantity);
                              } else {
                                _quantityController.text =
                                    widget.customer.quantity.toString();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Increase Button
                        IconButton(
                          onPressed: () => _adjustQuantity(0.5),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.success,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Default Quantity Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default: ${widget.customer.quantity}L',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _adjustQuantity(double delta) {
    final currentQuantity = double.tryParse(_quantityController.text) ?? 0;
    final newQuantity = (currentQuantity + delta).clamp(0.5, 10.0);
    _quantityController.text = newQuantity.toString();
    widget.onQuantityChange(newQuantity);
  }
}
