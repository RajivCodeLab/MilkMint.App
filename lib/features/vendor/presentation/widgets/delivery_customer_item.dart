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
    
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    
    // Responsive font sizes
    final nameFontSize = isSmallScreen ? 15.0 : isMediumScreen ? 16.0 : 17.0;
    final addressFontSize = isSmallScreen ? 12.0 : 13.0;
    final quantityLabelFontSize = isSmallScreen ? 13.0 : 14.0;

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
                SizedBox(
                  width: isSmallScreen ? 40 : 48,
                  height: isSmallScreen ? 40 : 48,
                  child: Checkbox(
                    value: isDelivered,
                    onChanged: (_) => widget.onToggle(),
                    activeColor: AppColors.success,
                  ),
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
                                fontSize: nameFontSize,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
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
                                    size: isSmallScreen ? 11 : 12,
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
                          fontSize: addressFontSize,
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
              LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust sizes based on available width
                  final isNarrow = constraints.maxWidth < 360;
                  final iconSize = isSmallScreen ? 20.0 : isMediumScreen ? 22.0 : 24.0;
                  final fontSize = isSmallScreen ? 13.0 : isMediumScreen ? 14.0 : 15.0;
                  final inputWidth = isNarrow ? 80.0 : 90.0;
                  final spacing = isNarrow ? 3.0 : 4.0;
                  final buttonSize = isSmallScreen ? 32.0 : 36.0;
                  
                  return Row(
                    children: [
                      Icon(
                        Icons.local_drink,
                        size: iconSize,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: spacing * 2),
                      Flexible(
                        flex: 0,
                        child: Text(
                          'Qty:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: quantityLabelFontSize,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing * 2),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease Button
                            SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: IconButton(
                                onPressed: () => _adjustQuantity(-0.5),
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.error,
                                padding: EdgeInsets.zero,
                                iconSize: iconSize,
                              ),
                            ),
                            SizedBox(width: spacing),

                            // Quantity Input
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: inputWidth),
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
                                    suffixStyle: TextStyle(fontSize: fontSize - 2),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isNarrow ? 6 : 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).brightness == Brightness.dark 
                                        ? AppColors.surfaceDark 
                                        : Colors.white.withValues(alpha: 0.8),
                                  ),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
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
                            ),
                            SizedBox(width: spacing),

                            // Increase Button
                            SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: IconButton(
                                onPressed: () => _adjustQuantity(0.5),
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.success,
                                padding: EdgeInsets.zero,
                                iconSize: iconSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing),

                      // Default Quantity Chip
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 5 : 6,
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
                                fontSize: fontSize - 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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

