import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/payment/payment.dart';

/// Payment card widget
class PaymentCard extends StatelessWidget {
  final Payment payment;
  final String customerName;
  final String? customerPhone;
  final VoidCallback? onTapUpi;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.customerName,
    this.customerPhone,
    this.onTapUpi,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Customer name and amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.paymentId,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${payment.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildModeBadge(),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // Payment details
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    DateFormat('dd MMM yyyy').format(payment.timestamp),
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.access_time,
                    'Time',
                    DateFormat('hh:mm a').format(payment.timestamp),
                  ),
                ),
              ],
            ),

            // Invoice ID if linked
            if (payment.invoiceId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.receipt_long,
                'Invoice',
                payment.invoiceId!,
              ),
            ],

            // Transaction ID for digital payments
            if (payment.transactionId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.confirmation_number,
                'Transaction ID',
                payment.transactionId!,
              ),
            ],

            // Notes if present
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.note,
                'Notes',
                payment.notes!,
              ),
            ],

            // UPI action button (if mode is not UPI yet and phone available)
            if (payment.mode == 'cash' && customerPhone != null && onTapUpi != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onTapUpi,
                icon: const Icon(Icons.phonelink, size: 18),
                label: const Text('Request UPI Payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeBadge() {
    Color color;
    IconData icon;
    String label;

    switch (payment.mode) {
      case 'cash':
        color = Colors.green;
        icon = Icons.money;
        label = 'CASH';
        break;
      case 'upi':
        color = Colors.blue;
        icon = Icons.phonelink;
        label = 'UPI';
        break;
      case 'bank_transfer':
        color = Colors.orange;
        icon = Icons.account_balance;
        label = 'BANK';
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
        label = payment.mode.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
