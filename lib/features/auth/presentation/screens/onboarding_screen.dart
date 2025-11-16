import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_role.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/auth_provider.dart';

/// Onboarding screen for new users
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).submitOnboarding(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      pincode: _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim(),
    );
    
    // Note: Loading state will be reset by the auth listener
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen to auth state changes for navigation
    ref.listen(authProvider, (previous, next) {
      next.when(
        authenticated: (user) {
          // Navigate to role-based home
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              _getHomeRoute(user.role),
              (route) => false,
            );
          }
        },
        error: (message) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        initial: () {},
        unauthenticated: () {},
        sendingOtp: () {},
        otpSent: (_) {},
        verifyingOtp: () {},
        authenticating: () {},
        requiresOnboarding: (_) {},
      );
    });

    return authState.maybeWhen(
      requiresOnboarding: (user) => _buildOnboardingForm(context, user),
      orElse: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _getHomeRoute(UserRole role) {
    switch (role) {
      case UserRole.vendor:
        return '/vendor-home';
      case UserRole.customer:
        return '/customer-home';
      case UserRole.deliveryAgent:
        return '/delivery-home';
    }
  }

  Widget _buildOnboardingForm(BuildContext context, User user) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to MilkBill!',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please complete your profile to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // First Name (Required)
                AppTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name (Required)
                AppTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email (Optional)
                AppTextField(
                  controller: _emailController,
                  label: 'Email (Optional)',
                  hint: 'your.email@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address (Optional)
                AppTextField(
                  controller: _addressController,
                  label: 'Address (Optional)',
                  hint: 'Street address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // City and Pincode Row
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        label: 'City (Optional)',
                        hint: 'City name',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _pincodeController,
                        label: 'Pincode (Optional)',
                        hint: '560001',
                        prefixIcon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.length != 6) {
                              return 'Invalid pincode';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: _isLoading ? null : _submitOnboarding,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Complete Profile'),
                  ),
                ),
                const SizedBox(height: 16),

                // Role info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(user.role),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Role: ${_getRoleName(user.role)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getRoleDescription(user.role),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        return 'Vendor';
      case UserRole.customer:
        return 'Customer';
      case UserRole.deliveryAgent:
        return 'Delivery Agent';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.vendor:
        return 'Manage your milk delivery business';
      case UserRole.customer:
        return 'Track your milk deliveries and bills';
      case UserRole.deliveryAgent:
        return 'Manage deliveries on the go';
    }
  }
}

