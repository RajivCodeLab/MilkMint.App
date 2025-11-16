import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../models/user_role.dart';
import '../../../auth/application/auth_provider.dart';

/// User profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initials = '${user.firstName?.substring(0, 1) ?? ''}${user.lastName?.substring(0, 1) ?? ''}'.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  // Profile Avatar
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
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: user.phone,
                      ),
                      if (user.email != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email!,
                        ),
                      ],
                      if (user.address != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: user.address!,
                        ),
                      ],
                      if (user.city != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'City',
                          value: user.city!,
                        ),
                      ],
                      if (user.pincode != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.pin_drop_outlined,
                          label: 'Pincode',
                          value: user.pincode!,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // App Preferences Section
                  Text(
                    'Preferences',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        value: _getLanguageName(user.language),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Account Status',
                        value: 'Active',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account Actions
                  Text(
                    'Account Actions',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.lock_outline,
                    title: 'Change Phone Number',
                    subtitle: 'Update your phone number',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone change coming soon!'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ActionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Settings',
                    subtitle: 'Manage your privacy preferences',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings coming soon!'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'kn':
        return 'ಕನ್ನಡ (Kannada)';
      default:
        return 'English';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onTap: onTap,
      ),
    );
  }
}
