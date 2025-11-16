import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Help & Support screen
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.support_agent,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'How can we help you?',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re here to assist you with any questions or concerns',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options
          Text(
            'Contact Us',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@milkmint.com',
            onTap: () async {
              final uri = Uri.parse('mailto:support@milkmint.com?subject=MilkMint Support Request');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: '+91 1800-XXX-XXXX',
            onTap: () async {
              final uri = Uri.parse('tel:+911800XXXXXXX');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.chat_outlined,
            title: 'WhatsApp Chat',
            subtitle: 'Chat with us on WhatsApp',
            onTap: () async {
              final uri = Uri.parse('https://wa.me/911800XXXXXXX?text=Hello, I need help with MilkMint');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),

          // FAQs
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _FAQCard(
            question: 'How do I mark daily deliveries?',
            answer: 'Go to the Deliveries section, select the date, and mark each customer as delivered or not delivered. You can also enter custom quantities.',
          ),
          _FAQCard(
            question: 'How are monthly bills generated?',
            answer: 'Bills are automatically generated on the 1st of each month based on delivery logs. You can also manually generate bills from the Billing section.',
          ),
          _FAQCard(
            question: 'Can I work offline?',
            answer: 'Yes! MilkMint works offline. Your delivery logs are saved locally and will sync automatically when you\'re back online.',
          ),
          _FAQCard(
            question: 'How do I change my language?',
            answer: 'Go to Settings → Language and select your preferred language (English, Hindi, or Kannada).',
          ),
          _FAQCard(
            question: 'How do customers pay their bills?',
            answer: 'Customers can pay via UPI, Cash, or Bank Transfer. All payment records are tracked in the Payments section.',
          ),
          const SizedBox(height: 24),

          // App Information
          Text(
            'App Information',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.info_outline,
            title: 'Version',
            value: '1.0.0 (Beta)',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            icon: Icons.update_outlined,
            title: 'Last Updated',
            value: 'November 2025',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms & Conditions coming soon!'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _InfoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy coming soon!'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Feedback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.feedback_outlined,
                  color: AppColors.accent,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Share Your Feedback',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help us improve MilkMint with your valuable feedback',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback form coming soon!'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Give Feedback'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQCard({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: value != null
            ? Text(
                value!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
