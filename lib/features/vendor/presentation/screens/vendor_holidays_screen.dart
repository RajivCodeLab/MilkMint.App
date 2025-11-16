import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common/application/holiday_provider.dart';

/// Vendor holidays screen
class VendorHolidaysScreen extends ConsumerWidget {
  const VendorHolidaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(holidayListProvider),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.beach_access_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Holiday Management'),
            SizedBox(height: 8),
            Text('Coming soon!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
