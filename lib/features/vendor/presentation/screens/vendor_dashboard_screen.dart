import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../common/application/holiday_provider.dart';
import '../../application/dashboard_provider.dart';
import '../../application/customer_provider.dart';
import '../../application/delivery_log_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/delivery_completion_card.dart';

/// Vendor dashboard screen - main home screen for vendors
class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  ConsumerState<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends ConsumerState<VendorDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load customer data and delivery logs on dashboard init
    Future.microtask(() {
      ref.read(customerProvider.notifier).loadCustomers();
      ref.read(deliveryLogProvider.notifier).loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh',
          ),
          // Notification bell with unread badge
          Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);
              final unreadCount = unreadCountAsync.maybeWhen(
                data: (count) => count,
                orElse: () => 0,
              );
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                    tooltip: 'Notifications',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingSection(),
              const SizedBox(height: 24),

              // Today's Stats
              Text(
                'Today\'s Overview',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildTodayStats(),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Delivery Completion Card
              Text(
                'Delivery Status',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final stats = ref.watch(dashboardStatsProvider);
                  return DeliveryCompletionCard(
                    totalCustomers: stats.totalDeliveries,
                    completedDeliveries: stats.completedDeliveries,
                    pendingDeliveries: stats.pendingDeliveries,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Upcoming Holidays section
             
              const SizedBox(height: 12),
              _buildUpcomingHolidaysCard(),
              const SizedBox(height: 24),

              // Recent Activity (placeholder)
              Text(
                'Recent Activity',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/delivery-log');
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Delivery'),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        items: VendorBottomNavItems.items,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() => _currentNavIndex = index);
    
    // Navigate based on index
    switch (index) {
      case 0:
        // Already on home, do nothing
        break;
      case 1:
        Navigator.pushNamed(context, '/customers');
        break;
      case 2:
        Navigator.pushNamed(context, '/delivery-log');
        break;
      case 3:
        Navigator.pushNamed(context, '/billing');
        break;
      case 4:
        Navigator.pushNamed(context, '/payments');
        break;
    }
  }

  Widget _buildGreetingSection() {
    final stats = ref.watch(dashboardStatsProvider);
    final today = DateTime.now();
    final dateStr = '${today.day} ${_getMonthName(today.month)} ${today.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Summary',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateStr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Completed',
                  '${stats.completedDeliveries}/${stats.totalDeliveries}',
                  Icons.check_circle_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Pending',
                  '${stats.pendingDeliveries}',
                  Icons.pending_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Revenue',
                  '₹${(stats.totalDailyQuantity * 50).toStringAsFixed(0)}',
                  Icons.currency_rupee,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildTodayStats() {
    final stats = ref.watch(dashboardStatsProvider);
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Active Customers',
            value: '${stats.activeCustomers}',
            icon: Icons.people_outline,
            color: AppColors.primary,
            onTap: () {
              Navigator.pushNamed(context, '/customers');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Daily Quantity',
            value: '${stats.totalDailyQuantity.toStringAsFixed(1)}L',
            icon: Icons.local_drink_outlined,
            color: AppColors.success,
            onTap: () {
              Navigator.pushNamed(context, '/delivery-log');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1,
      children: [
        QuickActionButton(
          icon: Icons.people_outline,
          label: 'Customers',
          color: AppColors.primary,
          onTap: () {
            Navigator.pushNamed(context, '/customers');
          },
        ),
        QuickActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'Billing',
          color: AppColors.secondary,
          onTap: () {
            Navigator.pushNamed(context, '/billing');
          },
        ),
        QuickActionButton(
          icon: Icons.payment_outlined,
          label: 'Payments',
          color: AppColors.accent,
          onTap: () {
            Navigator.pushNamed(context, '/payments');
          },
        ),
        QuickActionButton(
          icon: Icons.analytics_outlined,
          label: 'Reports',
          color: AppColors.info,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.reports);
          },
        ),
        QuickActionButton(
          icon: Icons.beach_access_outlined,
          label: 'Holidays',
          color: AppColors.warning,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.holidays);
          },
        ),
        QuickActionButton(
          icon: Icons.settings_outlined,
          label: 'Settings',
          color: AppColors.accent,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (list) {
        final items = list.take(3).toList();
        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.add_circle_outline,
                    title: 'No recent activity',
                    subtitle: 'Activities will appear here',
                    time: '',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(items.length, (index) {
                final n = items[index];
                final icon = _iconForNotificationType(n.type);
                final color = _colorForNotificationType(n.type);
                final title = n.title.isNotEmpty ? n.title : _titleForNotification(n);
                final subtitle = _subtitleForNotification(n);
                final time = _timeAgo(n.timestamp);

                return Column(
                  children: [
                    _buildActivityItem(
                      icon: icon,
                      title: title,
                      subtitle: subtitle,
                      time: time,
                      color: color,
                    ),
                    if (index != items.length - 1) const Divider(),
                  ],
                );
              }),
            ),
          ),
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      )),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.error_outline,
                title: 'Unable to load activity',
                subtitle: 'Tap refresh to try again',
                time: '',
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForNotificationType(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment_outlined;
      case 'delivery':
        return Icons.check_circle_outline;
      case 'customer':
        return Icons.person_add_alt_1_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForNotificationType(String type) {
    switch (type) {
      case 'payment':
        return AppColors.accent;
      case 'delivery':
        return AppColors.primary;
      case 'customer':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _titleForNotification(notification) {
    // Fallback title when none provided
    final type = notification.type ?? 'activity';
    switch (type) {
      case 'payment':
        return 'Payment received';
      case 'delivery':
        return 'Delivery completed';
      case 'customer':
        return 'New customer added';
      default:
        return notification.title ?? 'Activity';
    }
  }

  String _subtitleForNotification(n) {
    final data = n.data as Map<String, dynamic>? ?? {};
    if (n.type == 'payment') {
      final name = data['customerName'] ?? data['customerPhone'] ?? '';
      final amount = data['amount'] != null ? ' - ₹${data['amount']}' : '';
      return '$name$amount';
    }
    if (n.type == 'customer') {
      final name = data['name'] ?? '';
      final qty = data['quantity'] != null ? ' - ${data['quantity']}L/day' : '';
      return '$name$qty';
    }
    if (n.type == 'delivery') {
      final completed = data['completed'] ?? '';
      final total = data['total'] ?? '';
      if (completed != '' && total != '') return '$completed out of $total deliveries';
    }
    return n.body ?? '';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        time,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildUpcomingHolidaysCard() {
    final upcomingAsync = ref.watch(upcomingHolidaysProvider);

    return upcomingAsync.when(
      data: (holidays) {
        if (holidays.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Holidays', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text('No upcoming holidays', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        final items = holidays.take(3).toList();

        // Compact simple card version
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Holidays', style: AppTextStyles.titleMedium),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.holidays),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...items.map((h) {
                  final days = h.endDate.difference(h.startDate).inDays + 1;
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.beach_access, color: AppColors.warning, size: 20),
                        ),
                        title: Text(h.customerId, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${_formatDate(h.startDate)} → ${_formatDate(h.endDate)} • $days ${days == 1 ? 'day' : 'days'}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(h.status.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 12),
              Text('Loading upcoming holidays...'),
            ],
          ),
        ),
      ),
      error: (e, st) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Unable to load upcoming holidays', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              IconButton(
                onPressed: () => ref.refresh(upcomingHolidaysProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day} ${_getMonthName(d.month)} ${d.year}';
  }

  Future<void> _refreshDashboard() async {
    try {
      await Future.wait([
        ref.read(customerProvider.notifier).loadCustomers(),
        ref.read(deliveryLogProvider.notifier).loadLogs(),
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard refreshed'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
