import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/delivery/delivery_log.dart';

/// Delivery history card for customer
class DeliveryHistoryCard extends StatelessWidget {
  final DeliveryLog delivery;

  const DeliveryHistoryCard({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM');
    final isDelivered = delivery.delivered;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDelivered
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDelivered ? Icons.check_circle : Icons.cancel,
                color: isDelivered ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Date and quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(delivery.date),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDelivered
                        ? '${delivery.quantityDelivered?.toStringAsFixed(1) ?? '0.0'}L delivered'
                        : 'No delivery',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity badge
            if (isDelivered && delivery.quantityDelivered != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${delivery.quantityDelivered!.toStringAsFixed(1)}L',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
