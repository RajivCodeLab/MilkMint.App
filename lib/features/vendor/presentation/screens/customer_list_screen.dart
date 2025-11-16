import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/customer/customer.dart';
import '../../application/customer_provider.dart';
import '../widgets/customer_list_item.dart';

/// Customer list screen for vendors
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final filteredCustomers = ref.watch(filteredCustomersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.8),
              ),
              onChanged: (query) {
                ref.read(customerProvider.notifier).setSearchQuery(query);
              },
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip(
                  icon: Icons.people,
                  label: 'Total: ${state.customers.length}',
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.check_circle,
                  label: 'Active: ${state.activeCount}',
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.local_drink,
                  label: '${state.totalDailyQuantity.toStringAsFixed(1)}L/day',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(customerProvider.notifier).loadCustomers();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return CustomerListItem(
                              customer: customer,
                              onTap: () => _navigateToEdit(customer),
                              onCall: () => _makeCall(customer.phone),
                              onWhatsApp: () => _openWhatsApp(customer.phone),
                              onToggleStatus: () => _toggleStatus(customer),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = ref.read(customerProvider).searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No customers found' : 'No customers yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try a different search term'
                : 'Add your first customer to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Customer'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final currentSort = ref.read(customerProvider).sortOption;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildSortOption(
                title: 'Name (A-Z)',
                icon: Icons.sort_by_alpha,
                option: CustomerSortOption.name,
                isSelected: currentSort == CustomerSortOption.name,
              ),
              _buildSortOption(
                title: 'Quantity (High to Low)',
                icon: Icons.local_drink,
                option: CustomerSortOption.quantity,
                isSelected: currentSort == CustomerSortOption.quantity,
              ),
              _buildSortOption(
                title: 'Active First',
                icon: Icons.check_circle,
                option: CustomerSortOption.activeFirst,
                isSelected: currentSort == CustomerSortOption.activeFirst,
              ),
              _buildSortOption(
                title: 'Recently Added',
                icon: Icons.access_time,
                option: CustomerSortOption.recentlyAdded,
                isSelected: currentSort == CustomerSortOption.recentlyAdded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required CustomerSortOption option,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(customerProvider.notifier).setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  void _navigateToAdd() {
    Navigator.pushNamed(context, '/add-customer').then((_) {
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  void _navigateToEdit(Customer customer) {
    Navigator.pushNamed(
      context,
      '/edit-customer',
      arguments: customer,
    ).then((_) {
      ref.read(customerProvider.notifier).loadCustomers();
    });
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make phone call')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Remove + and format for WhatsApp
    final cleanPhone = phone.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open WhatsApp')),
        );
      }
    }
  }

  Future<void> _toggleStatus(Customer customer) async {
    try {
      await ref.read(customerProvider.notifier).toggleCustomerStatus(
            customer.customerId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customer.active
                  ? '${customer.name} marked as inactive'
                  : '${customer.name} marked as active',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

