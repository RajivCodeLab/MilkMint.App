import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/offline/offline_sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget to display sync status badge
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({
    super.key,
    this.showDetails = false,
  });

  final bool showDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return syncStatusAsync.when(
      data: (syncStatus) {
        if (syncStatus.pendingCount == 0 && !syncStatus.isSyncing) {
          return const SizedBox.shrink();
        }

        return _buildBadge(context, syncStatus);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBadge(BuildContext context, SyncStatus syncStatus) {
    final Color color;
    final IconData icon;
    final String text;

    if (syncStatus.isSyncing) {
      color = Colors.blue;
      icon = Icons.sync;
      text = 'Syncing...';
    } else if (syncStatus.pendingCount > 0) {
      color = Colors.orange;
      icon = Icons.cloud_upload;
      text = '${syncStatus.pendingCount} pending';
    } else {
      color = Colors.green;
      icon = Icons.cloud_done;
      text = 'Synced';
    }

    if (showDetails) {
      return _buildDetailedBadge(context, syncStatus, color, icon, text);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (syncStatus.isSyncing)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBadge(
    BuildContext context,
    SyncStatus syncStatus,
    Color color,
    IconData icon,
    String text,
  ) {
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (syncStatus.isSyncing)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (syncStatus.lastSyncTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last sync: ${timeFormat.format(syncStatus.lastSyncTime!)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (syncStatus.syncedCount > 0 || syncStatus.failedCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (syncStatus.syncedCount > 0) ...[
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${syncStatus.syncedCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (syncStatus.failedCount > 0) ...[
                  Icon(Icons.error, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${syncStatus.failedCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (syncStatus.error != null) ...[
            const SizedBox(height: 8),
            Text(
              syncStatus.error!,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Sync status indicator for app bar
class AppBarSyncIndicator extends ConsumerWidget {
  const AppBarSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return syncStatusAsync.when(
      data: (syncStatus) {
        if (syncStatus.isSyncing) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          );
        }

        if (syncStatus.pendingCount > 0) {
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                onPressed: () {
                  _showSyncDetails(context, syncStatus);
                },
                tooltip: '${syncStatus.pendingCount} items pending sync',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${syncStatus.pendingCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showSyncDetails(BuildContext context, SyncStatus syncStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sync, color: Colors.blue),
            SizedBox(width: 12),
            Text('Sync Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(
              'Pending',
              syncStatus.pendingCount.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Synced',
              syncStatus.syncedCount.toString(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Failed',
              syncStatus.failedCount.toString(),
              Colors.red,
            ),
            if (syncStatus.lastSyncTime != null) ...[
              const Divider(height: 24),
              Text(
                'Last sync: ${DateFormat('dd MMM, hh:mm a').format(syncStatus.lastSyncTime!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
