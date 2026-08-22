import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for storing and retrieving UI preferences (theme mode and
/// locale) from SharedPreferences.
class SettingsStorageService {
  static SettingsStorageService? _instance;
  late final SharedPreferences _prefs;

  SettingsStorageService._();

  static Future<SettingsStorageService> init() async {
    if (_instance == null) {
      _instance = SettingsStorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  static SettingsStorageService get instance {
    assert(_instance != null, 'SettingsStorageService instance not initialized!');
    return _instance!;
  }

  /// Clears the cached singleton so the next [init] call picks up a fresh
  /// [SharedPreferences] instance. Only meant for test isolation between
  /// cases that call [SharedPreferences.setMockInitialValues].
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString('theme_mode', themeMode);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString('theme_mode');
  }

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString('locale', languageCode);
  }

  Future<String?> getLocale() async {
    return _prefs.getString('locale');
  }
}
