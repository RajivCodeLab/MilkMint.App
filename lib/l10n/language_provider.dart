import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_service.dart';

/// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Language state notifier
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier(this._prefs) : super(const Locale('en')) {
    _loadLanguage();
  }

  final SharedPreferences _prefs;
  static const String _languageKey = 'app_language';

  /// Load saved language from preferences
  Future<void> _loadLanguage() async {
    final languageCode = _prefs.getString(_languageKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  /// Change app language
  Future<void> changeLanguage(AppLanguage language) async {
    state = Locale(language.code);
    await _prefs.setString(_languageKey, language.code);
  }

  /// Get current AppLanguage enum
  AppLanguage get currentLanguage {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == state.languageCode,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Provider for language state
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});
