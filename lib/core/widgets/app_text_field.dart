import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Text field variants
enum AppTextFieldVariant {
  outlined, // Default outlined style
  filled, // Filled background style
}

/// Reusable custom text field widget with MilkBill styling
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final AppTextFieldVariant variant;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.variant = AppTextFieldVariant.outlined,
    this.contentPadding,
  });

  /// Outlined text field (default)
  const AppTextField.outlined({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.contentPadding,
  }) : variant = AppTextFieldVariant.outlined;

  /// Filled text field with background
  const AppTextField.filled({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.contentPadding,
  }) : variant = AppTextFieldVariant.filled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        filled: true,
        fillColor: variant == AppTextFieldVariant.filled
            ? AppColors.grey.withValues(alpha: 0.5)
            : (isDark 
                ? AppColors.surfaceDark 
                : Colors.white.withValues(alpha: 0.8)),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primary, size: 22)
            : null,
        prefix: prefix,
        suffixIcon: _buildSuffix(),
        suffix: suffix,
        border: _getBorder(context),
        enabledBorder: _getEnabledBorder(context),
        focusedBorder: _getFocusedBorder(context),
        errorBorder: _getErrorBorder(context),
        focusedErrorBorder: _getFocusedErrorBorder(context),
        disabledBorder: _getDisabledBorder(context),
        labelStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        helperStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        errorStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.error,
        ),
        counterStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget? _buildSuffix() {
    if (suffixIcon == null) return null;

    return GestureDetector(
      onTap: onSuffixTap,
      child: Icon(
        suffixIcon,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }

  InputBorder _getBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.grey,
        width: 1.5,
      ),
    );
  }

  InputBorder _getEnabledBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.grey,
        width: 1.5,
      ),
    );
  }

  InputBorder _getFocusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    );
  }

  InputBorder _getErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    );
  }

  InputBorder _getFocusedErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    );
  }

  InputBorder _getDisabledBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.grey.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }
}

/// Phone number text field with country code
class AppPhoneTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const AppPhoneTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label ?? 'Phone Number',
      hint: hint ?? '1234567890',
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      prefix: const Padding(
        padding: EdgeInsets.only(left: 12, right: 8),
        child: Text(
          '+91',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }
}

/// Search text field
class AppSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField.filled(
      hint: hint ?? 'Search...',
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true ? Icons.clear : null,
      onSuffixTap: onClear,
      textInputAction: TextInputAction.search,
    );
  }
}

/// OTP text field
class AppOtpTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final FocusNode? focusNode;

  const AppOtpTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'OTP',
      hint: '123456',
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.lock_outline,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

