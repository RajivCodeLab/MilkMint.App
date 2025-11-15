import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Supported languages
enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'हिन्दी'),
  kannada('kn', 'ಕನ್ನಡ');

  const AppLanguage(this.code, this.name);
  final String code;
  final String name;
}

/// Localization service for managing app translations
class LocalizationService {
  LocalizationService(this.locale);

  final Locale locale;
  Map<String, dynamic>? _localizedStrings;

  /// Load translations from JSON file
  Future<void> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/i18n/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap;
  }

  /// Get translated string by key path (e.g., 'auth.login')
  String translate(String key, {Map<String, dynamic>? params}) {
    if (_localizedStrings == null) {
      return key;
    }

    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    if (value is! String) {
      return key;
    }

    // Replace parameters if provided
    if (params != null && params.isNotEmpty) {
      String result = value;
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{{$paramKey}}', paramValue.toString());
      });
      return result;
    }

    return value;
  }

  /// Static helper to get LocalizationService from context
  static LocalizationService of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService)!;
  }
}

/// Localization delegate
class AppLocalizationDelegate extends LocalizationsDelegate<LocalizationService> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.values
        .map((lang) => lang.code)
        .contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    final localization = LocalizationService(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

/// Extension for easy access to translations
extension LocalizationExtension on BuildContext {
  String t(String key, {Map<String, dynamic>? params}) {
    return LocalizationService.of(this).translate(key, params: params);
  }
}
