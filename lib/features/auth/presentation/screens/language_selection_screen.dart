import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/language_provider.dart';
import '../../../../l10n/localization_service.dart';

/// Language selection screen - first screen on app launch
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final currentLanguage = currentLocale.languageCode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Icon
              const Icon(
                Icons.shopping_bag_outlined,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'MilkMint',
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Milk Delivery Management',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Language Selection Title
              Text(
                'Select Your Language',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                'अपनी भाषा चुनें',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Language Options
              _LanguageOption(
                title: 'English',
                subtitle: 'English',
                languageCode: 'en',
                isSelected: currentLanguage == 'en',
                onTap: () => _selectLanguage(context, ref, 'en'),
              ),
              const SizedBox(height: 12),

              _LanguageOption(
                title: 'हिंदी',
                subtitle: 'Hindi',
                languageCode: 'hi',
                isSelected: currentLanguage == 'hi',
                onTap: () => _selectLanguage(context, ref, 'hi'),
              ),
              const SizedBox(height: 12),

              _LanguageOption(
                title: 'ಕನ್ನಡ',
                subtitle: 'Kannada',
                languageCode: 'kn',
                isSelected: currentLanguage == 'kn',
                onTap: () => _selectLanguage(context, ref, 'kn'),
              ),
              const SizedBox(height: 64),

              // Continue Button (shown after selection)
              if (currentLanguage.isNotEmpty)
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, WidgetRef ref, String code) {
    final notifier = ref.read(languageProvider.notifier);
    final language = code == 'en'
        ? AppLanguage.english
        : code == 'hi'
            ? AppLanguage.hindi
            : AppLanguage.kannada;
    notifier.changeLanguage(language);
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Language Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  languageCode.toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Language Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
