import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/auth_provider.dart';
import '../widgets/phone_input_field.dart';

/// Phone number input screen for OTP login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      next.when(
        initial: () {},
        unauthenticated: () {},
        sendingOtp: () {
          setState(() => _isLoading = true);
        },
        otpSent: (verificationId) {
          setState(() => _isLoading = false);
          // Navigate to OTP screen
          Navigator.pushNamed(
            context,
            '/otp-verification',
            arguments: {
              'verificationId': verificationId,
              'phoneNumber': _phoneController.text.trim(),
            },
          );
        },
        verifyingOtp: () {},
        authenticating: () {},
        authenticated: (user) {},
        requiresOnboarding: (user) {},
        error: (message) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 24),

                // App Logo
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Welcome to MilkBill',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter your phone number to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Phone Number Input
                PhoneInputField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Send OTP',
                          style: AppTextStyles.button,
                        ),
                ),
                const SizedBox(height: 24),

                // Info Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We will send you a verification code',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    
    // Format phone number with country code if not present
    final formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber
        : '+91$phoneNumber';

    await ref.read(authProvider.notifier).sendOtp(formattedPhone);
  }
}
