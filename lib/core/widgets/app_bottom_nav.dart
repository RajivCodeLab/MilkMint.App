import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Navigation item model
class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}

/// Custom bottom navigation bar with MilkBill styling
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68, maxHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _AppBottomNavItemWidget(
                item: items[index],
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom nav item widget
class _AppBottomNavItemWidget extends StatelessWidget {
  final AppBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _AppBottomNavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isActive ? 48 : 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? AppColors.primaryGradient
                        : null,
                    color: isActive ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      size: isActive ? 20 : 19,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                // Label with animation
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 16),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: isActive ? 11.5 : 10.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      letterSpacing: isActive ? 0.1 : 0,
                      height: 1.0,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vendor bottom navigation items
class VendorBottomNavItems {
  static const List<AppBottomNavItem> items = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Customers',
    ),
    AppBottomNavItem(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: 'Deliveries',
    ),
    AppBottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Billing',
    ),
    AppBottomNavItem(
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
      label: 'Payments',
    ),
  ];
}

/// Customer bottom navigation items
class CustomerBottomNavItems {
  static const List<AppBottomNavItem> items = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'History',
    ),
    AppBottomNavItem(
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      label: 'Payments',
    ),
    AppBottomNavItem(
      icon: Icons.beach_access_outlined,
      activeIcon: Icons.beach_access,
      label: 'Holidays',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];
}

/// Delivery agent bottom navigation items
class AgentBottomNavItems {
  static const List<AppBottomNavItem> items = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: 'Deliveries',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];
}

/// Floating action button with mint styling
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final bool useGradient;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: useGradient ? null : AppColors.primary,
      child: useGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: Colors.white),
              ),
            )
          : Icon(icon, color: Colors.white),
    );
  }
}

/// Extended floating action button with text
class AppExtendedFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool useGradient;

  const AppExtendedFab({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: useGradient ? null : AppColors.primary,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

