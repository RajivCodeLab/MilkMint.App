import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/user_role.dart';
import '../../application/auth_provider.dart';

/// Role resolution and redirect screen
class RoleResolutionScreen extends ConsumerStatefulWidget {
  const RoleResolutionScreen({super.key});

  @override
  ConsumerState<RoleResolutionScreen> createState() =>
      _RoleResolutionScreenState();
}

class _RoleResolutionScreenState extends ConsumerState<RoleResolutionScreen> {
  @override
  void initState() {
    super.initState();
    // Delay to show animation, then redirect based on role
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _redirectBasedOnRole();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Message
                Text(
                  'Welcome!',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Phone Number
                if (user != null)
                  Text(
                    user.phone,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Role Information
                if (user != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(user.role),
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getRoleName(user.role),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Loading Indicator
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),

                  Text(
                    'Setting up your account...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _redirectBasedOnRole() {
    final user = ref.read(currentUserProvider);
    
    if (user == null) {
      // Shouldn't happen, but handle it
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    switch (user.role) {
      case UserRole.vendor:
        Navigator.pushReplacementNamed(context, '/vendor-home');
        break;
      case UserRole.customer:
        Navigator.pushReplacementNamed(context, '/customer-home');
        break;
      case UserRole.deliveryAgent:
        Navigator.pushReplacementNamed(context, '/delivery-home');
        break;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.vendor:
        return Icons.store;
      case UserRole.customer:
        return Icons.person;
      case UserRole.deliveryAgent:
        return Icons.delivery_dining;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.vendor:
        return 'Vendor Account';
      case UserRole.customer:
        return 'Customer Account';
      case UserRole.deliveryAgent:
        return 'Delivery Agent';
    }
  }
}
