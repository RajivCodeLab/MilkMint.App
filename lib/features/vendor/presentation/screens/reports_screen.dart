import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/dashboard_provider.dart';
import '../../application/customer_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(customerProvider.notifier).loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);
    final customerState = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: customerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(customerProvider.notifier).loadCustomers(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Revenue Overview'),
                    const SizedBox(height: 12),
                    _buildRevenueCard(stats),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Customer Insights'),
                    const SizedBox(height: 12),
                    _buildCustomerInsights(stats),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Delivery Performance'),
                    const SizedBox(height: 12),
                    _buildDeliveryInsights(stats),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Top Customers'),
                    const SizedBox(height: 12),
                    _buildTopCustomers(customerState),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Frequency Distribution'),
                    const SizedBox(height: 12),
                    _buildFrequencyDistribution(customerState),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.border),
      ),
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'This Year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildRevenueCard(DashboardStats stats) {
    final multiplier = _getPeriodMultiplier();
    final estimatedRevenue = stats.totalMonthlyRevenue * multiplier;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Revenue', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('₹${_formatCurrency(estimatedRevenue)}', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.trending_up, color: AppColors.success, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMetric('Daily Quantity', '${stats.totalDailyQuantity.toStringAsFixed(1)} L', Icons.local_drink_outlined, AppColors.primary),
            const SizedBox(height: 12),
            _buildMetric('Active Customers', '${stats.activeCustomers}', Icons.people_outline, AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCustomerInsights(DashboardStats stats) {
    return Row(
      children: [
        Expanded(child: _buildInsightCard('Total', '${stats.totalCustomers}', Icons.group_outlined, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildInsightCard('Active', '${stats.activeCustomers}', Icons.check_circle_outline, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildInsightCard('Inactive', '${stats.totalCustomers - stats.activeCustomers}', Icons.pause_circle_outline, AppColors.warning)),
      ],
    );
  }

  Widget _buildDeliveryInsights(DashboardStats stats) {
    return Row(
      children: [
        Expanded(child: _buildInsightCard('Pending', '${stats.pendingDeliveries}', Icons.schedule_outlined, AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _buildInsightCard('Done', '${stats.completedDeliveries}', Icons.done_all_outlined, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildInsightCard('Rate', '${stats.completionPercentage.toStringAsFixed(0)}%', Icons.trending_up, AppColors.info)),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomers(CustomerState state) {
    final top = state.customers.where((c) => c.active).toList()..sort((a, b) => b.quantity.compareTo(a.quantity));
    final customers = top.take(5).toList();

    if (customers.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No active customers', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)))));
    }

    return Card(
      child: Column(
        children: customers.asMap().entries.map((e) {
          final customer = e.value;
          final revenue = customer.quantity * customer.rate * 30;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(customer.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('${customer.quantity}L/day • ${customer.frequency}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            trailing: Text('₹${_formatCurrency(revenue)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.success)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFrequencyDistribution(CustomerState state) {
    final freq = <String, int>{};
    for (final c in state.customers.where((c) => c.active)) {
      freq[c.frequency] = (freq[c.frequency] ?? 0) + 1;
    }

    if (freq.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No active customers', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)))));
    }

    final total = freq.values.fold(0, (sum, count) => sum + count);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: freq.entries.map((e) {
            final pct = (e.value / total) * 100;
            final color = _getFrequencyColor(e.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getFrequencyLabel(e.key), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text('${e.value} (${pct.toStringAsFixed(0)}%)', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFrequencyLabel(String f) {
    return {'daily': 'Daily', 'alternate': 'Alternate Days', 'weekly': 'Weekly', 'custom': 'Custom'}[f] ?? f;
  }

  Color _getFrequencyColor(String f) {
    return {'daily': AppColors.primary, 'alternate': AppColors.success, 'weekly': AppColors.warning, 'custom': AppColors.info}[f] ?? AppColors.textSecondary;
  }

  double _getPeriodMultiplier() {
    return {'Today': 1 / 30, 'This Week': 7 / 30, 'This Month': 1.0, 'This Year': 12.0}[_selectedPeriod] ?? 1.0;
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.picture_as_pdf, color: AppColors.error), title: const Text('Export as PDF'), onTap: () { Navigator.pop(context); _showComingSoon('PDF export'); }),
            ListTile(leading: const Icon(Icons.table_chart, color: AppColors.success), title: const Text('Export as Excel'), onTap: () { Navigator.pop(context); _showComingSoon('Excel export'); }),
            ListTile(leading: const Icon(Icons.share, color: AppColors.primary), title: const Text('Share Report'), onTap: () { Navigator.pop(context); _showComingSoon('Report sharing'); }),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon!'), backgroundColor: AppColors.info));
  }
}
