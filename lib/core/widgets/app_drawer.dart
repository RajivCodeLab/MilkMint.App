import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../router/app_routes.dart';
import '../../models/user_role.dart';
import '../../features/auth/application/auth_provider.dart';

/// Custom navigation drawer for MilkMint app
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userRole = ref.watch(userRoleProvider);

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, user),
              const SizedBox(height: 16),

              // Navigation items
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      if (userRole == UserRole.vendor) ..._buildVendorItems(context),
                      if (userRole == UserRole.customer) ..._buildCustomerItems(context),
                      if (userRole == UserRole.deliveryAgent) ..._buildAgentItems(context),
                      const Divider(height: 32),
                      ..._buildCommonItems(context, ref),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final displayName = user != null && user.firstName != null && user.lastName != null
        ? '${user.firstName} ${user.lastName}'
        : user?.phone ?? 'Guest';
    final initials = user?.firstName?.substring(0, 1).toUpperCase() ?? user?.phone.substring(0, 1) ?? 'U';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile avatar on the left
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User info on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name or phone number
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (user?.address != null) ...[
                  const SizedBox(height: 4),
                  // Address
                  Text(
                    user!.address!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.role.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVendorItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/vendor-home');
        },
      ),
      _DrawerItem(
        icon: Icons.people_outline,
        title: 'Customers',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/customers');
        },
      ),
      _DrawerItem(
        icon: Icons.local_shipping_outlined,
        title: 'Deliveries',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/delivery-log');
        },
      ),
      _DrawerItem(
        icon: Icons.receipt_long_outlined,
        title: 'Billing',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/billing');
        },
      ),
      _DrawerItem(
        icon: Icons.payments_outlined,
        title: 'Payments',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/payments');
        },
      ),
      _DrawerItem(
        icon: Icons.bar_chart_outlined,
        title: 'Reports',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/reports');
        },
      ),
    ];
  }

  List<Widget> _buildCustomerItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.home_outlined,
        title: 'Home',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/customer-home');
        },
      ),
      _DrawerItem(
        icon: Icons.history_outlined,
        title: 'Delivery History',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/delivery-history');
        },
      ),
      _DrawerItem(
        icon: Icons.receipt_outlined,
        title: 'My Bills',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/customer-bills');
        },
      ),
      _DrawerItem(
        icon: Icons.beach_access_outlined,
        title: 'Holiday Requests',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/holiday-request');
        },
      ),
    ];
  }

  List<Widget> _buildAgentItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.home_outlined,
        title: 'Home',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/agent-home');
        },
      ),
      _DrawerItem(
        icon: Icons.local_shipping_outlined,
        title: 'Deliveries',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/agent-deliveries');
        },
      ),
    ];
  }

  List<Widget> _buildCommonItems(BuildContext context, WidgetRef ref) {
    return [
      _DrawerItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notifications');
        },
      ),
      _DrawerItem(
        icon: Icons.person_outline,
        title: 'Profile',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile');
        },
      ),
      _DrawerItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/settings');
        },
      ),
      _DrawerItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/support');
        },
      ),
      _DrawerItem(
        icon: Icons.logout,
        title: 'Logout',
        iconColor: AppColors.error,
        textColor: AppColors.error,
        onTap: () async {
          debugPrint('🔴 Logout button pressed');
          // Get the auth notifier and close drawer immediately
          final authNotifier = ref.read(authProvider.notifier);
          Navigator.pop(context); // Close drawer
          
          debugPrint('🔴 Drawer closed, calling logout...');
          await authNotifier.logout();
          debugPrint('🔴 Logout completed, waiting for state to settle...');
          
          // Wait a moment for auth state to update completely
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Navigate to language selection directly (bypassing splash check)
          if (context.mounted) {
            debugPrint('🔴 Context is mounted, navigating to language selection');
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.languageSelection,
              (route) => false, // Remove all previous routes
            );
            debugPrint('🔴 Navigation completed');
          } else {
            debugPrint('❌ Context not mounted!');
          }
        },
      ),
    ];
  }
}

/// Drawer item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = iconColor ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Icon(
        icon,
        color: itemColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? itemColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

