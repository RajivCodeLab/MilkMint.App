import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../features/auth/application/auth_provider.dart';
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
    final greeting = ref.watch(greetingProvider);
    final greetingType = ref.watch(greetingIconProvider);
    final user = ref.watch(currentUserProvider);
    
    IconData icon;
    if (greetingType == 'morning') {
      icon = Icons.wb_sunny_outlined;
    } else if (greetingType == 'afternoon') {
      icon = Icons.wb_sunny;
    } else {
      icon = Icons.nightlight_outlined;
    }

    final displayName = user?.firstName != null && user?.lastName != null
        ? '${user!.firstName} ${user.lastName}'
        : 'there';

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
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $displayName!',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Let\'s make today productive!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
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
            // TODO: Navigate to holiday requests
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
    // Placeholder for recent activity
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityItem(
              icon: Icons.add_circle_outline,
              title: 'New customer added',
              subtitle: 'Rajesh Kumar - 2 liters/day',
              time: '2 hours ago',
              color: AppColors.success,
            ),
            const Divider(),
            _buildActivityItem(
              icon: Icons.check_circle_outline,
              title: 'Delivery completed',
              subtitle: '32 out of 45 deliveries',
              time: '3 hours ago',
              color: AppColors.primary,
            ),
            const Divider(),
            _buildActivityItem(
              icon: Icons.payment_outlined,
              title: 'Payment received',
              subtitle: 'Priya Sharma - ₹1,200',
              time: 'Yesterday',
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
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
