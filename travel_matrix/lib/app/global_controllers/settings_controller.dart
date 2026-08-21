import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsStorageService _storage = SettingsStorageService.instance;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// Loads the persisted theme mode and locale, falling back to the
  /// defaults above when nothing has been saved yet.
  Future<void> initialize() async {
    final storedThemeMode = await _storage.getThemeMode();
    if (storedThemeMode != null) {
      _themeMode = _themeModeFromName(storedThemeMode);
    }

    final storedLocale = await _storage.getLocale();
    if (storedLocale != null) {
      _locale = Locale(storedLocale);
    }

    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _storage.saveThemeMode(_themeMode.name);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _storage.saveThemeMode(_themeMode.name);
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('pt') : const Locale('en');
    _storage.saveLocale(_locale.languageCode);
    notifyListeners();
  }

  ThemeMode _themeModeFromName(String name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.light,
    );
  }
}
