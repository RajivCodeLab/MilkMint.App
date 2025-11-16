import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/delivery/delivery_log.dart';
import '../../application/customer_provider.dart';
import '../../application/delivery_log_provider.dart';
import '../widgets/delivery_customer_item.dart';

/// Delivery log screen for vendors to mark daily deliveries
class DeliveryLogScreen extends ConsumerStatefulWidget {
  const DeliveryLogScreen({super.key});

  @override
  ConsumerState<DeliveryLogScreen> createState() => _DeliveryLogScreenState();
}

class _DeliveryLogScreenState extends ConsumerState<DeliveryLogScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerProvider.notifier).loadCustomers();
      ref.read(deliveryLogProvider.notifier).loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerProvider);
    final deliveryState = ref.watch(deliveryLogProvider);
    final activeCustomers = customerState.customers.where((c) => c.active).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Logging'),
        actions: [
          // Sync Status Indicator
          if (deliveryState.pendingSyncCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: deliveryState.isSyncing
                        ? AppColors.info.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (deliveryState.isSyncing)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                          ),
                        )
                      else
                        const Icon(
                          Icons.cloud_upload,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        deliveryState.isSyncing
                            ? 'Syncing...'
                            : '${deliveryState.pendingSyncCount} pending',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: deliveryState.isSyncing
                              ? AppColors.info
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: deliveryState.isSyncing
                ? null
                : () => ref.read(deliveryLogProvider.notifier).syncPendingLogs(),
            tooltip: 'Sync now',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(-1),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_selectedDate),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _isToday() ? null : () => _changeDate(1),
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Delivered',
                  value: deliveryState.deliveredCount.toString(),
                  color: AppColors.success,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.pending,
                  label: 'Pending',
                  value: deliveryState.pendingCount.toString(),
                  color: AppColors.warning,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.local_drink,
                  label: 'Quantity',
                  value: '${deliveryState.totalQuantityDelivered.toStringAsFixed(1)}L',
                  color: AppColors.info,
                ),
              ],
            ),
          ),

          // Customer List
          Expanded(
            child: customerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : activeCustomers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(customerProvider.notifier).loadCustomers();
                          await ref.read(deliveryLogProvider.notifier).loadLogs();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: activeCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = activeCustomers[index];
                            DeliveryLog? log;
                            
                            try {
                              log = deliveryState.todayLogs.firstWhere(
                                (log) => log.customerId == customer.customerId,
                              );
                            } catch (e) {
                              // Log not found, will be null
                            }

                            return DeliveryCustomerItem(
                              customer: customer,
                              log: log,
                              onToggle: () => _toggleDelivery(
                                customer.customerId,
                                customer.name,
                                customer.quantity,
                              ),
                              onQuantityChange: (quantity) => _updateQuantity(
                                customer.customerId,
                                quantity,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Auto-adjust based on available width
          final isNarrow = constraints.maxWidth < 100;
          final iconSize = isNarrow ? 16.0 : 20.0;
          final labelFontSize = isNarrow ? 10.0 : 12.0;
          final valueFontSize = isNarrow ? 16.0 : 20.0;
          final spacing = isNarrow ? 4.0 : 8.0;
          
          return Row(
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: valueFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No active customers',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add customers to start logging deliveries',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/customers');
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Go to Customers'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    ref.read(deliveryLogProvider.notifier).loadLogs(date: _selectedDate);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      ref.read(deliveryLogProvider.notifier).loadLogs(date: _selectedDate);
    }
  }

  Future<void> _toggleDelivery(
    String customerId,
    String customerName,
    double quantity,
  ) async {
    try {
      await ref.read(deliveryLogProvider.notifier).toggleDelivery(
            customerId: customerId,
            customerName: customerName,
            quantity: quantity,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(String customerId, double quantity) async {
    try {
      await ref.read(deliveryLogProvider.notifier).updateQuantity(
            customerId: customerId,
            quantity: quantity,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
