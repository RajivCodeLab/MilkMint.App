import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom button variants for MilkBill app
enum AppButtonVariant {
  primary, // Mint gradient button
  secondary, // Outlined mint button
  accent, // Yellow accent button for CTAs
  text, // Text-only button
  danger, // Red for destructive actions
}

/// Custom button sizes
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Reusable custom button widget with MilkBill styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isEnabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  });

  /// Primary button (mint gradient)
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.primary;

  /// Secondary button (outlined mint)
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.secondary;

  /// Accent button (yellow for CTAs)
  const AppButton.accent({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.accent;

  /// Text button
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.text;

  /// Danger button (red for destructive actions)
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildButtonChild();
    final isDisabled = !isEnabled || isLoading || onPressed == null;

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = _buildPrimaryButton(buttonChild, isDisabled);
        break;
      case AppButtonVariant.secondary:
        button = _buildSecondaryButton(buttonChild, isDisabled);
        break;
      case AppButtonVariant.accent:
        button = _buildAccentButton(buttonChild, isDisabled);
        break;
      case AppButtonVariant.text:
        button = _buildTextButton(buttonChild, isDisabled);
        break;
      case AppButtonVariant.danger:
        button = _buildDangerButton(buttonChild, isDisabled);
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary ||
                    variant == AppButtonVariant.accent ||
                    variant == AppButtonVariant.danger
                ? Colors.white
                : AppColors.primary,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: _getIconSpacing()),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  Widget _buildPrimaryButton(Widget child, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppColors.primaryGradient,
        color: isDisabled ? AppColors.grey : null,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(Widget child, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled ? AppColors.textDisabled : AppColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        side: BorderSide(
          color: isDisabled ? AppColors.grey : AppColors.primary,
          width: 2,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAccentButton(Widget child, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppColors.accentGradient,
        color: isDisabled ? AppColors.grey : null,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            padding: _getPadding(),
            child: Center(
              child: DefaultTextStyle(
                style: _getTextStyle().copyWith(
                  color: isDisabled ? AppColors.textDisabled : AppColors.textPrimary,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(Widget child, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled ? AppColors.textDisabled : AppColors.primary,
        padding: _getPadding(),
      ),
      child: child,
    );
  }

  Widget _buildDangerButton(Widget child, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey : AppColors.error,
        foregroundColor: Colors.white,
        padding: _getPadding(),
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: child,
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.large:
        return 16;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: variant == AppButtonVariant.primary ||
              variant == AppButtonVariant.danger
          ? Colors.white
          : AppColors.primary,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 13);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 15);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 17);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}
