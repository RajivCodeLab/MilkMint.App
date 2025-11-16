import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Stat card widget for displaying key metrics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Auto-adjust based on available width
            final isNarrow = constraints.maxWidth < 160;
            final iconSize = isNarrow ? 40.0 : 48.0;
            final iconInnerSize = isNarrow ? 20.0 : 24.0;
            final valueFontSize = isNarrow ? 24.0 : 32.0;
            final titleFontSize = isNarrow ? 11.0 : 12.0;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: iconInnerSize,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: valueFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
