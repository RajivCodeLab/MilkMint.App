import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../models/user_role.dart';
import '../../../../features/auth/application/auth_provider.dart';
import '../../application/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: user == null ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(user: user),
            const Divider(height: 1),
            _Section(title: 'Account', children: [
              _Tile(icon: Icons.person_outline, title: 'Edit Profile', subtitle: 'Update your personal information', onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile)),
              _Tile(icon: Icons.phone_outlined, title: 'Phone Number', subtitle: user.phone, onTap: () => _show(context, 'Change Phone')),
              _Tile(icon: Icons.business_outlined, title: 'Business Details', subtitle: 'Manage your business', onTap: () => _show(context, 'Business Details')),
            ]),
            _Section(title: 'App Settings', children: [
              _Tile(icon: Icons.language_outlined, title: 'Language', subtitle: _getLang(user.language), onTap: () => _showLangDialog(context, ref, user.language)),
              _Tile(icon: Icons.palette_outlined, title: 'Theme', subtitle: isDark ? 'Dark Mode' : 'Light Mode', trailing: Switch(value: isDark, onChanged: (v) => _show(context, 'Theme'), activeTrackColor: AppColors.primary.withValues(alpha: 0.5), thumbColor: WidgetStateProperty.all(AppColors.primary))),
              _Tile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Manage preferences', onTap: () => _show(context, 'Notifications')),
            ]),
            _Section(title: 'Data & Storage', children: [
              _Tile(icon: Icons.backup_outlined, title: 'Backup & Sync', subtitle: 'Manage backup', onTap: () => _show(context, 'Backup')),
              _Tile(icon: Icons.storage_outlined, title: 'Storage', subtitle: 'Manage app storage', onTap: () => _show(context, 'Storage')),
              _Tile(icon: Icons.download_outlined, title: 'Offline Data', subtitle: 'Sync deliveries', onTap: () => _show(context, 'Offline')),
            ]),
            _Section(title: 'Help & Support', children: [
              _Tile(icon: Icons.help_outline, title: 'Help Center', subtitle: 'FAQs and guides', onTap: () => _show(context, 'Help')),
              _Tile(icon: Icons.contact_support_outlined, title: 'Contact Support', subtitle: 'Get help', onTap: () => _show(context, 'Support')),
              _Tile(icon: Icons.rate_review_outlined, title: 'Rate Us', subtitle: 'Share feedback', onTap: () => _show(context, 'Rate')),
            ]),
            _Section(title: 'About', children: [
              const _Tile(icon: Icons.info_outline, title: 'App Version', subtitle: '1.0.0 (Beta)'),
              _Tile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () => _show(context, 'Terms')),
              _Tile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => _show(context, 'Privacy')),
            ]),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: OutlinedButton.icon(onPressed: () => _logout(context, ref), icon: const Icon(Icons.logout, color: AppColors.error), label: const Text('Logout', style: TextStyle(color: AppColors.error)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), minimumSize: const Size(double.infinity, 48)))),
            Padding(padding: const EdgeInsets.all(16), child: TextButton.icon(onPressed: () => _delete(context), icon: const Icon(Icons.delete_outline, color: AppColors.error), label: const Text('Delete Account', style: TextStyle(color: AppColors.error)), style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 48)))),
          ],
        ),
      ),
    );
  }

  String _getLang(String c) => {'en': 'English', 'hi': 'हिंदी', 'kn': 'ಕನ್ನಡ'}[c] ?? 'English';

  void _show(BuildContext c, String f) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('$f coming soon!'), backgroundColor: AppColors.info));

  void _showLangDialog(BuildContext c, WidgetRef r, String cur) {
    showModalBottomSheet(context: c, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 16),
      Text('Select Language', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
      const Divider(),
      _LangOption(code: 'en', name: 'English', current: cur),
      _LangOption(code: 'hi', name: 'हिंदी (Hindi)', current: cur),
      _LangOption(code: 'kn', name: 'ಕನ್ನಡ (Kannada)', current: cur),
      const SizedBox(height: 16),
    ]));
  }

  void _logout(BuildContext c, WidgetRef r) {
    showDialog(context: c, builder: (c) => AlertDialog(title: const Text('Logout'), content: const Text('Are you sure?'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
      TextButton(onPressed: () async { Navigator.pop(c); await r.read(authProvider.notifier).logout(); if (c.mounted) Navigator.pushNamedAndRemoveUntil(c, AppRoutes.login, (r) => false); }, child: const Text('Logout', style: TextStyle(color: AppColors.error))),
    ]));
  }

  void _delete(BuildContext c) {
    showDialog(context: c, builder: (c) => AlertDialog(title: const Text('Delete Account'), content: const Text('This cannot be undone.'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
      TextButton(onPressed: () { Navigator.pop(c); _show(c, 'Delete'); }, child: const Text('Delete', style: TextStyle(color: AppColors.error))),
    ]));
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(children: [
        CircleAvatar(radius: 40, backgroundColor: Colors.white.withValues(alpha: 0.3), child: Text('${user.firstName[0]}${user.lastName[0]}'.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${user.firstName} ${user.lastName}', style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.phone, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text((user.role as UserRole).displayName.toUpperCase(), style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10))),
        ])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.white)),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ...children,
      const Divider(height: 1),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _Tile({required this.icon, required this.title, this.subtitle, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.primary, size: 24)),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null),
      onTap: onTap,
    );
  }
}

class _LangOption extends ConsumerWidget {
  final String code;
  final String name;
  final String current;
  const _LangOption({required this.code, required this.name, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = code == current;
    return ListTile(
      title: Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      trailing: selected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: selected ? null : () async {
        Navigator.pop(context);
        try {
          await ref.read(userProvider.notifier).updateLanguage(code);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language updated!'), backgroundColor: AppColors.success));
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating language'), backgroundColor: AppColors.error));
        }
      },
    );
  }
}
