import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/invoice/invoice.dart';

/// Invoice card widget
class BillingInvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final String customerName;
  final VoidCallback? onViewPdf;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onShare;

  const BillingInvoiceCard({
    super.key,
    required this.invoice,
    required this.customerName,
    this.onViewPdf,
    this.onMarkPaid,
    this.onShare,
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
          color: AppColors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
            // Header: Customer name and status
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
                        invoice.invoiceId,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),

            const Divider(height: 24),

            // Invoice details
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Total Liters',
                    '${invoice.totalLiters.toStringAsFixed(1)}L',
                    Icons.local_drink,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Amount',
                    '₹${invoice.amount.toStringAsFixed(2)}',
                    Icons.currency_rupee,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Generated',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message:
                                'PDF not yet generated. The invoice PDF and generation timestamp will appear here once ready.',
                            preferBelow: false,
                            child: Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.generatedAt != null
                            ? DateFormat('dd MMM').format(invoice.generatedAt!)
                            : 'Pending',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // View PDF button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: invoice.pdfUrl != null ? onViewPdf : null,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('View PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Share button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: invoice.pdfUrl != null ? onShare : null,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Mark as paid button (only if unpaid)
                if (!invoice.paid)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onMarkPaid,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Mark Paid'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),

                // Paid date (if paid)
                if (invoice.paid && invoice.paidAt != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Paid on',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(invoice.paidAt!),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = invoice.paid ? Colors.green : Colors.orange;
    final label = invoice.paid ? 'PAID' : 'UNPAID';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

