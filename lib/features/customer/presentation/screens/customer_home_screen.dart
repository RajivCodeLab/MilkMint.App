import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/application/auth_provider.dart';
import '../../application/customer_home_provider.dart';
import '../widgets/bill_summary_card.dart';
import '../widgets/delivery_history_card.dart';

/// Customer home screen showing bill summary, deliveries, and holiday options
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load home data on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerHomeProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(customerHomeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(customerHomeProvider.notifier).loadHomeData(),
        child: homeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome header
                    _buildWelcomeHeader(user?.phone ?? 'Customer'),

                    const SizedBox(height: 24),

                    // Bill summary card
                    if (homeState.currentMonthBill != null)
                      BillSummaryCard(
                        invoice: homeState.currentMonthBill!,
                        onViewPdf: () => _viewPdf(homeState.currentMonthBill!.pdfUrl),
                        onPayNow: () => _payNow(homeState.currentMonthBill!.amount),
                      ),

                    const SizedBox(height: 16),

                    // Pending dues warning
                    if (homeState.hasPendingDues) _buildPendingDuesCard(homeState),

                    const SizedBox(height: 16),

                    // Stats row
                    _buildStatsRow(homeState),

                    const SizedBox(height: 24),

                    // Recent deliveries section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Deliveries',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/delivery-history');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Delivery list
                    if (homeState.recentDeliveries.isEmpty)
                      _buildEmptyDeliveries()
                    else
                      ...homeState.recentDeliveries.take(5).map(
                            (delivery) => DeliveryHistoryCard(delivery: delivery),
                          ),

                    const SizedBox(height: 24),

                    // Active holidays section
                    if (homeState.activeHolidays.isNotEmpty) ...[
                      Text(
                        'Active Holidays',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...homeState.activeHolidays.map(_buildHolidayCard),
                      const SizedBox(height: 24),
                    ],

                    // Quick actions
                    _buildQuickActions(),
                  ],
                ),
              ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        items: CustomerBottomNavItems.items,
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/holiday-request');
        },
        icon: Icons.beach_access,
        tooltip: 'Request Holiday',
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
        Navigator.pushNamed(context, '/delivery-history');
        break;
      case 2:
        Navigator.pushNamed(context, '/payments');
        break;
      case 3:
        Navigator.pushNamed(context, '/holiday-request');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildWelcomeHeader(String phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Welcome Back!',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            phone,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDuesCard(CustomerHomeState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Payment',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${state.pendingAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _payNow(state.pendingAmount),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CustomerHomeState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Deliveries',
            '${state.deliveriesThisMonth}',
            'This month',
            Icons.local_shipping,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Liters',
            '${state.totalLitersThisMonth.toStringAsFixed(1)}L',
            'This month',
            Icons.local_drink,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeliveries() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'No deliveries yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayCard(holiday) {
    final dateFormat = DateFormat('dd MMM');
    Color statusColor;
    switch (holiday.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.beach_access, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dateFormat.format(holiday.startDate)} - ${dateFormat.format(holiday.endDate)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (holiday.reason != null && holiday.reason!.isNotEmpty)
                    Text(
                      holiday.reason!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                holiday.status.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Payment History',
                Icons.history,
                Colors.blue,
                () {
                  // TODO: Navigate to payment history
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Contact Vendor',
                Icons.phone,
                Colors.green,
                () => _contactVendor(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: color),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _viewPdf(String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice not yet generated')),
      );
      return;
    }

    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open PDF')),
        );
      }
    }
  }

  Future<void> _payNow(double amount) async {
    // UPI payment deep link
    final upiId = 'vendor@upi'; // TODO: Get from vendor profile
    final upiUrl = Uri.parse(
      'upi://pay?pa=$upiId&pn=MilkMint&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Milk Bill Payment',
    );

    try {
      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No UPI app found. Please install a UPI app.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch UPI: $e')),
        );
      }
    }
  }

  void _contactVendor() async {
    // TODO: Get vendor phone from API
    final vendorPhone = '9876543210';
    final whatsappUrl = Uri.parse('https://wa.me/91$vendorPhone');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open WhatsApp')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }
}
