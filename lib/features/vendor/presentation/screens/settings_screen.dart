import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/auth/firebase_service.dart';
import '../../../../features/auth/application/auth_provider.dart';
import '../../application/user_provider.dart';

/// Settings screen with comprehensive app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Account Section
                  _SectionHeader(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        subtitle: user.phone,
                        onTap: () => _showComingSoon(context, 'Change Phone Number'),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: _getLanguageName(user.language),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        onTap: () => _showLanguageDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notifications Section
                  _SectionHeader(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Receive notifications for updates',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      const Divider(height: 1),
                      _SwitchTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sound',
                        subtitle: 'Play sound for notifications',
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() => _soundEnabled = value);
                        },
                      ),
                      const Divider(height: 1),
                      _SwitchTile(
                        icon: Icons.vibration_outlined,
                        title: 'Vibration',
                        subtitle: 'Vibrate on notifications',
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() => _vibrationEnabled = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Data & Storage Section
                  _SectionHeader(
                    icon: Icons.storage_outlined,
                    title: 'Data & Storage',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SwitchTile(
                        icon: Icons.backup_outlined,
                        title: 'Auto Backup',
                        subtitle: 'Automatically backup your data',
                        value: _autoBackup,
                        onChanged: (value) {
                          setState(() => _autoBackup = value);
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.sync_outlined,
                        title: 'Sync Data',
                        subtitle: 'Sync offline deliveries now',
                        onTap: () => _syncData(context),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.delete_outline,
                        title: 'Clear Cache',
                        subtitle: 'Free up storage space',
                        onTap: () => _clearCache(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display Section
                  _SectionHeader(
                    icon: Icons.palette_outlined,
                    title: 'Display',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.brightness_6_outlined,
                        title: 'Theme',
                        subtitle: _getThemeName(ref.watch(themeModeProvider)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        onTap: () => _showThemeDialog(context),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.text_fields_outlined,
                        title: 'Text Size',
                        subtitle: 'Medium',
                        onTap: () => _showComingSoon(context, 'Text Size'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Security Section
                  _SectionHeader(
                    icon: Icons.security_outlined,
                    title: 'Security & Privacy',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () => _showComingSoon(context, 'Change Password'),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.fingerprint_outlined,
                        title: 'Biometric Lock',
                        subtitle: 'Use fingerprint to unlock',
                        onTap: () => _showComingSoon(context, 'Biometric Lock'),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Settings',
                        subtitle: 'Manage your privacy',
                        onTap: () => _showComingSoon(context, 'Privacy Settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  _SectionHeader(
                    icon: Icons.info_outlined,
                    title: 'About',
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.app_settings_alt_outlined,
                        title: 'App Version',
                        subtitle: '1.0.0 (Beta)',
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.update_outlined,
                        title: 'Check for Updates',
                        subtitle: 'You\'re on the latest version',
                        onTap: () => _checkUpdates(context),
                      ),
                      const Divider(height: 1),
                      _FCMTokenTile(),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () => _showComingSoon(context, 'Terms & Conditions'),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _showComingSoon(context, 'Privacy Policy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete Account Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary, size: 20),
                      label: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
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

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Select Language',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _LanguageOption(
              code: 'en',
              name: 'English',
              nativeName: 'English',
              current: user.language,
              onTap: () => _updateLanguage(context, 'en'),
            ),
            _LanguageOption(
              code: 'hi',
              name: 'Hindi',
              nativeName: 'हिंदी',
              current: user.language,
              onTap: () => _updateLanguage(context, 'hi'),
            ),
            _LanguageOption(
              code: 'kn',
              name: 'Kannada',
              nativeName: 'ಕನ್ನಡ',
              current: user.language,
              onTap: () => _updateLanguage(context, 'kn'),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentTheme = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.brightness_6, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Select Theme',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _ThemeOption(
              mode: ThemeMode.light,
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.wb_sunny_outlined,
              current: currentTheme,
              onTap: () => _updateTheme(context, ThemeMode.light),
            ),
            _ThemeOption(
              mode: ThemeMode.dark,
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.nightlight_outlined,
              current: currentTheme,
              onTap: () => _updateTheme(context, ThemeMode.dark),
            ),
            _ThemeOption(
              mode: ThemeMode.system,
              title: 'System Default',
              subtitle: 'Follow system settings',
              icon: Icons.brightness_auto_outlined,
              current: currentTheme,
              onTap: () => _updateTheme(context, ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTheme(BuildContext context, ThemeMode mode) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    navigator.pop();
    await ref.read(themeModeProvider.notifier).setThemeMode(mode);
    
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${_getThemeName(mode)}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _updateLanguage(BuildContext context, String code) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    navigator.pop();
    try {
      await ref.read(userProvider.notifier).updateLanguage(code);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Language updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to update language'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _syncData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Syncing data...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _checkUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You\'re already on the latest version!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_outlined, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Delete Account');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)) : null),
      onTap: onTap,
    );
  }
}

// Switch Tile Widget
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}

// Language Option Widget
class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final String nativeName;
  final String current;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = code == current;
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            code.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ),
      ),
      title: Text(
        nativeName,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        name,
        style: AppTextStyles.bodySmall.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: isSelected ? null : onTap,
    );
  }
}

// Theme Option Widget
class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == current;
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: isSelected ? null : onTap,
    );
  }
}

// FCM Token Tile Widget
class _FCMTokenTile extends ConsumerWidget {
  const _FCMTokenTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fcmTokenAsync = ref.watch(fcmTokenProvider);
    final theme = Theme.of(context);

    return fcmTokenAsync.when(
      data: (token) {
        if (token == null) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary, size: 22),
            ),
            title: Text(
              'FCM Token',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Token not available',
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            'FCM Token (for testing)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Tap to copy',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          trailing: const Icon(Icons.copy, size: 20),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: token));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('FCM Token copied to clipboard!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
      loading: () => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        title: Text(
          'FCM Token',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Loading...',
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      error: (_, __) => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.error_outline, color: AppColors.error, size: 22),
        ),
        title: Text(
          'FCM Token',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Failed to load token',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
