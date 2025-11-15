import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom OTP input field with 6 boxes
class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final Function(String)? onCompleted;

  const OtpInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onCompleted,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    // Listen to main controller changes
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChange() {
    final text = widget.controller.text;
    for (int i = 0; i < 6; i++) {
      if (i < text.length) {
        _controllers[i].text = text[i];
      } else {
        _controllers[i].clear();
      }
    }
  }

  void _onChanged(String value, int index) {
    // Update main controller
    final currentOtp = List.generate(6, (i) => _controllers[i].text).join();
    widget.controller.text = currentOtp;

    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field - unfocus and trigger completion
        _focusNodes[index].unfocus();
        if (widget.onCompleted != null && currentOtp.length == 6) {
          widget.onCompleted!(currentOtp);
        }
      }
    } else {
      // Handle backspace - move to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 50,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  filled: true,
                  fillColor: widget.enabled
                      ? (isDark ? AppColors.surfaceDark : Colors.white.withOpacity(0.8))
                      : AppColors.border.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: AppTextStyles.headlineMedium,
                onChanged: (value) => _onChanged(value, index),
                onTap: () {
                  // Clear field on tap for better UX
                  if (_controllers[index].text.isNotEmpty) {
                    _controllers[index].clear();
                  }
                },
                onEditingComplete: () {
                  if (index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
                autofocus: index == 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
