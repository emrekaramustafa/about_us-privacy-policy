import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
class SupportedLocales {
  static const Locale turkish = Locale('tr');
  static const Locale english = Locale('en');
  static const Locale spanish = Locale('es');
  static const Locale french = Locale('fr');
  static const Locale german = Locale('de');
  static const Locale portuguese = Locale('pt');

  static const List<Locale> all = [
    turkish,
    english,
    spanish,
    french,
    german,
    portuguese,
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'pt':
        return 'Português';
      default:
        return locale.languageCode;
    }
  }

  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'pt':
        return '🇧🇷';
      default:
        return '🌐';
    }
  }
}

/// Locale state notifier
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
      // If no saved locale, state remains null (will use system locale)
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  Future<void> clearLocale() async {
    state = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
    } catch (e) {
      debugPrint('Error clearing locale: $e');
    }
  }

  /// Get the effective locale (user selected or system default)
  Locale getEffectiveLocale(Locale systemLocale) {
    if (state != null) {
      return state!;
    }
    
    // Check if system locale is supported
    for (final supportedLocale in SupportedLocales.all) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Default to English if system locale is not supported
    return SupportedLocales.english;
  }
}

/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
