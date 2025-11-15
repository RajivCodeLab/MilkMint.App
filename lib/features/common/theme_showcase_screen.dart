import 'package:flutter/material.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';

/// Demo screen showcasing all MilkBill custom widgets
class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Buttons
          const _SectionHeader('Buttons'),
          const SizedBox(height: 16),
          AppButton.primary(
            text: 'Primary Button',
            onPressed: () {},
            icon: Icons.check,
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            text: 'Secondary Button',
            onPressed: () {},
            icon: Icons.edit,
          ),
          const SizedBox(height: 12),
          AppButton.accent(
            text: 'Accent Button (Pay Now)',
            onPressed: () {},
            icon: Icons.payment,
          ),
          const SizedBox(height: 12),
          AppButton.danger(
            text: 'Danger Button',
            onPressed: () {},
            icon: Icons.delete,
          ),
          const SizedBox(height: 12),
          AppButton.text(
            text: 'Text Button',
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          AppButton.primary(
            text: 'Loading Button',
            onPressed: () {},
            isLoading: true,
          ),
          const SizedBox(height: 12),
          AppButton.primary(
            text: 'Disabled Button',
            onPressed: null,
          ),

          const SizedBox(height: 32),

          // Section: Cards
          const _SectionHeader('Cards'),
          const SizedBox(height: 16),
          AppCard.elevated(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elevated Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text('This is an elevated card with shadow.'),
              ],
            ),
          ),
          AppCard.outlined(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outlined Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text('This is an outlined card with border.'),
              ],
            ),
          ),
          AppCard.filled(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filled Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text('This is a filled card with background.'),
              ],
            ),
          ),
          AppInfoCard(
            title: 'Info Card',
            subtitle: 'With icon and chevron',
            icon: Icons.info_outline,
            iconColor: AppColors.primary,
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: AppStatsCard(
                  label: 'Delivered',
                  value: '45',
                  icon: Icons.check_circle,
                  iconColor: AppColors.success,
                  subtitle: 'Today',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatsCard(
                  label: 'Revenue',
                  value: '₹12.5K',
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.accent,
                  subtitle: 'This month',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          AppEmptyCard(
            message: 'No data found',
            icon: Icons.inbox_outlined,
            actionText: 'Add New',
            onAction: () {},
          ),

          const SizedBox(height: 32),

          // Section: Text Fields
          const _SectionHeader('Text Fields'),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Customer Name',
            hint: 'Enter customer name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          AppPhoneTextField(
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          AppTextField.filled(
            label: 'Search',
            hint: 'Search customers...',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Address',
            hint: 'Enter full address',
            maxLines: 3,
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          AppOtpTextField(),

          const SizedBox(height: 32),

          // Section: Colors
          const _SectionHeader('Color Palette'),
          const SizedBox(height: 16),
          _ColorShowcase(),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        onPressed: () {},
        tooltip: 'Add Customer',
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ColorShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ColorTile('Primary', AppColors.primary),
        _ColorTile('Primary Dark', AppColors.primaryDark),
        _ColorTile('Accent', AppColors.accent),
        _ColorTile('Success', AppColors.success),
        _ColorTile('Error', AppColors.error),
        _ColorTile('Warning', AppColors.warning),
        _ColorTile('Grey', AppColors.grey),
        _ColorTile('Text Primary', AppColors.textPrimary),
      ],
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String name;
  final Color color;

  const _ColorTile(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey, width: 1),
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getContrastColor(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              fontSize: 10,
              color: _getContrastColor(color).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
